/**
 * CDS Query UI – Backend
 * Express API that uses abap-adt-api to run queries and list CDS views.
 */
import 'dotenv/config';
import path from 'path';
import { fileURLToPath } from 'url';
import http from 'http';
import express from 'express';
import cors from 'cors';
import { ADTClient, createSSLConfig, session_types } from 'abap-adt-api';
import OpenAI from 'openai';
import fs from 'fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CDS_EXT = '.ddls.abap';

// Normalize SAP base URL: trim and remove trailing slash (avoids double slashes)
function normalizeSapUrl(url) {
  if (!url || typeof url !== 'string') return url;
  return url.trim().replace(/\/+$/, '');
}

// ─── SAP ADT client (lazy init) ─────────────────────────────────────
let adtClient = null;

function getAdtClient() {
  if (adtClient) return adtClient;
  const missing = ['SAP_URL', 'SAP_USER', 'SAP_PASSWORD'].filter((k) => !process.env[k]);
  if (missing.length) throw new Error(`Missing env: ${missing.join(', ')}`);
  const baseUrl = normalizeSapUrl(process.env.SAP_URL);
  adtClient = new ADTClient(
    baseUrl,
    process.env.SAP_USER.trim(),
    process.env.SAP_PASSWORD,
    String(process.env.SAP_CLIENT || '100'),
    String(process.env.SAP_LANGUAGE || 'EN'),
    createSSLConfig(true) // allow corporate/self-signed certificates
  );
  adtClient.stateful = session_types.stateful;
  return adtClient;
}

// Resolve CDS source directory: relative paths are from project root (parent of server/)
function getCdsBasePath() {
  const raw = process.env.CDS_SOURCE_PATH || path.join(__dirname, '..', 'cds-views');
  return path.isAbsolute(raw) ? raw : path.resolve(path.join(__dirname, '..'), raw);
}

// ─── Local CDS view list (from zanalytics-cds) ───────────────────────
function listLocalCdsViews() {
  const basePath = getCdsBasePath();
  const views = [];
  function scan(dir) {
    if (!fs.existsSync(dir)) return;
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (entry.isDirectory()) scan(path.join(dir, entry.name));
      else if (entry.name.endsWith(CDS_EXT)) views.push(entry.name.replace(CDS_EXT, ''));
    }
  }
  scan(basePath);
  return views.sort();
}

// ─── Express app ────────────────────────────────────────────────────
const app = express();
const PORT = Number(process.env.PORT) || 3001;

app.use(cors());
app.use(express.json());

// Serve static files: try dist/ (Vite build) first, fall back to public/
const distPath = path.join(__dirname, '..', 'dist');
const publicPath = path.join(__dirname, '..', 'public');
if (fs.existsSync(distPath)) {
  app.use(express.static(distPath));
} else {
  app.use(express.static(publicPath));
}

// Connection check timeout (ms) — avoid hanging if SAP is unreachable
const CONNECTION_CHECK_TIMEOUT_MS = 25000;

// ─── API: Connection check ──────────────────────────────────────────
app.get('/api/connection', async (req, res) => {
  try {
    const client = getAdtClient();
    const ticketPromise = client.reentranceTicket();
    const timeoutPromise = new Promise((_, reject) =>
      setTimeout(() => reject(new Error('Connection timed out. Check SAP_URL, network, and firewall.')), CONNECTION_CHECK_TIMEOUT_MS)
    );
    await Promise.race([ticketPromise, timeoutPromise]);
    res.json({ ok: true, message: 'Connected' });
  } catch (err) {
    const msg = err.message || 'Connection failed';
    // Surface common causes for easier troubleshooting
    const hint =
      msg.includes('ECONNREFUSED') ? ' SAP may be down or the URL/port is wrong.'
      : msg.includes('ETIMEDOUT') || msg.includes('timed out') ? ' Network/firewall may be blocking; try from the same network as SAP.'
      : msg.includes('401') || msg.includes('Unauthorized') ? ' Check SAP_USER and SAP_PASSWORD in .env.'
      : msg.includes('403') || msg.includes('Forbidden') ? ' User may lack authorization or wrong SAP_CLIENT.'
      : msg.includes('certificate') || msg.includes('UNABLE_TO_VERIFY') ? ' SSL certificate issue; ensure createSSLConfig(true) is used.'
      : '';
    res.status(503).json({ ok: false, message: msg + hint });
  }
});

// ─── API: List CDS views (local) ──────────────────────────────────────
app.get('/api/cds-views', (req, res) => {
  try {
    const views = listLocalCdsViews();
    res.json({ views });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── API: Run query ──────────────────────────────────────────────────
app.post('/api/query', async (req, res) => {
  try {
    const body = req.body;
    if (!body || typeof body !== 'object') {
      return res.status(400).json({ error: 'Request body must be JSON with type, and ddicEntityName or sqlQuery.' });
    }
    const client = getAdtClient();
    const { type, ddicEntityName, sqlQuery, rowNumber = 500, decode = true } = body;

    if (type === 'tableContents') {
      const name = (ddicEntityName != null && String(ddicEntityName).trim()) ? String(ddicEntityName).trim() : '';
      if (!name) return res.status(400).json({ error: 'Select a CDS view first, or switch to Custom SQL and enter a query.' });
      const result = await client.tableContents(name, rowNumber, decode, sqlQuery || undefined);
      return res.json({ status: 'success', result });
    }

    if (type === 'runQuery') {
      const q = (sqlQuery != null && String(sqlQuery).trim()) ? String(sqlQuery).trim() : '';
      if (!q) return res.status(400).json({ error: 'Enter a SQL query in the Custom SQL box.' });
      const result = await client.runQuery(q, rowNumber, decode);
      return res.json({ status: 'success', result });
    }

    res.status(400).json({ error: 'Invalid type. Use "tableContents" (CDS view) or "runQuery" (custom SQL).' });
  } catch (err) {
    res.status(500).json({ error: err.message || 'Query failed' });
  }
});

// ─── LLM client (Groq or OpenAI — switch to avoid Groq accessibility issues)
// Set LLM_PROVIDER=openai to use OpenAI instead of Groq (e.g. when Groq is blocked by firewall).
let llmClient = null;
let llmModel = null;

function getLLM() {
  if (llmClient) return { client: llmClient, model: llmModel };

  const provider = (process.env.LLM_PROVIDER || 'groq').toLowerCase();

  if (provider === 'openai') {
    const key = process.env.OPENAI_API_KEY;
    if (!key || key.startsWith('sk-PASTE'))
      throw new Error('OPENAI_API_KEY not configured. Set it in .env or use LLM_PROVIDER=groq with GROQ_API_KEY.');
    llmClient = new OpenAI({
      apiKey: key,
      baseURL: process.env.OPENAI_API_BASE || undefined, // optional custom base (e.g. Azure, OpenRouter)
      timeout: 60000,
    });
    llmModel = process.env.OPENAI_MODEL || 'gpt-4o-mini';
  } else {
    // default: Groq
    const key = process.env.GROQ_API_KEY;
    if (!key || key.startsWith('PASTE'))
      throw new Error('GROQ_API_KEY not configured in .env — get a free key at https://console.groq.com');
    llmClient = new OpenAI({
      apiKey: key,
      baseURL: 'https://api.groq.com/openai/v1',
      timeout: 60000,
    });
    llmModel = process.env.GROQ_MODEL || 'llama-3.3-70b-versatile';
  }

  return { client: llmClient, model: llmModel };
}

// Read CDS view sources for AI context
function readCdsViewSource(viewName) {
  const basePath = getCdsBasePath();
  const filePath = path.join(basePath, viewName + CDS_EXT);
  if (fs.existsSync(filePath)) return fs.readFileSync(filePath, 'utf-8');
  // try subfolders
  function findIn(dir) {
    if (!fs.existsSync(dir)) return null;
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      if (e.isDirectory()) { const r = findIn(path.join(dir, e.name)); if (r) return r; }
      else if (e.name.toUpperCase() === (viewName + CDS_EXT).toUpperCase())
        return fs.readFileSync(path.join(dir, e.name), 'utf-8');
    }
    return null;
  }
  return findIn(basePath);
}

function buildCdsContext() {
  const views = listLocalCdsViews();
  const summaries = views.map(v => {
    const src = readCdsViewSource(v);
    if (!src) return `- ${v}: (source not available)`;
    // Extract the SQL view name and label from annotations
    const labelMatch = src.match(/@EndUserText\.label:\s*'([^']+)'/i);
    const label = labelMatch ? labelMatch[1] : '';
    // Extract field list (simplified: lines starting with spaces that have "as" keyword)
    const fields = [];
    for (const line of src.split('\n')) {
      const m = line.match(/\s+\S+.*\bas\b\s+(\w+)/i);
      if (m) fields.push(m[1]);
    }
    return `- ${v}: ${label}${fields.length ? ' | Fields: ' + fields.join(', ') : ''}`;
  });
  return summaries.join('\n');
}

const SYSTEM_PROMPT = `You are a SAP CDS Query Assistant. You help users query SAP S/4HANA CDS views using natural language.

AVAILABLE CDS VIEWS:
{CDS_CONTEXT}

RULES:
1. When the user asks a question about data, determine which CDS view to query.
2. Generate an ABAP SQL SELECT statement. Use the CDS view name as the table (e.g. SELECT * FROM ZFIN_I_BILLRATE_V).
3. ABAP SQL syntax: field names in the SELECT list, WHERE clause with comparisons, no backticks, no semicolons. Use single quotes for string literals.
4. Keep queries simple and efficient. Default to 100 rows unless the user asks for more.
5. If the user's question is ambiguous, pick the most likely CDS view and explain your choice.
6. If the user just wants to explore a view, use: SELECT * FROM <view> with a reasonable row limit.

RESPONSE FORMAT — you MUST respond with valid JSON (no markdown, no code fences):
{
  "explanation": "Brief explanation of what you're querying and why",
  "sql": "SELECT ... FROM ... WHERE ...",
  "viewName": "THE_CDS_VIEW_NAME",
  "rowLimit": 100,
  "chartSuggestion": {
    "type": "bar|line|area|pie|none",
    "xKey": "field_name_for_x_axis",
    "yKeys": ["field_name_for_y_axis"]
  }
}

If the user is asking a general question (not a data query), set sql to null and just provide an explanation.`;

// ─── API: Chat (NLP to SQL via Groq or OpenAI) ───────────────────────
app.post('/api/chat', async (req, res) => {
  try {
    const body = req.body;
    if (!body || typeof body !== 'object') {
      return res.status(400).json({ error: 'Request body must be JSON with a "message" field.' });
    }
    const { message, history = [] } = body;
    const msg = (message != null && String(message).trim()) ? String(message).trim() : '';
    if (!msg) return res.status(400).json({ error: 'Type a message in the Ask Finnie chat box.' });

    const { client, model } = getLLM();
    const cdsContext = buildCdsContext();
    const systemMsg = SYSTEM_PROMPT.replace('{CDS_CONTEXT}', cdsContext);

    // Build messages — standard OpenAI chat format (system + history + user)
    const messages = [
      { role: 'system', content: systemMsg },
      ...history.slice(-10)
        .filter(m => m.role === 'user' || m.role === 'assistant')
        .map(m => ({ role: m.role, content: m.content })),
      { role: 'user', content: msg }
    ];

    const completion = await client.chat.completions.create({
      model,
      messages,
      temperature: 0.2,
      max_tokens: 1000,
    });

    const raw = completion.choices[0]?.message?.content?.trim() || '';

    // Parse AI response
    let parsed;
    try {
      // Strip markdown code fences if the model wraps in ```json
      const cleaned = raw.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/i, '').trim();
      parsed = JSON.parse(cleaned);
    } catch {
      // If parsing fails, treat as plain text explanation
      return res.json({ reply: { explanation: raw, sql: null, data: null, chartSuggestion: null } });
    }

    // If there's a SQL query, execute it
    let data = null;
    let queryError = null;
    if (parsed.sql) {
      try {
        const client = getAdtClient();
        const limit = parsed.rowLimit || 100;
        data = await client.runQuery(parsed.sql, limit, true);
      } catch (err) {
        queryError = err.message;
      }
    }

    res.json({
      reply: {
        explanation: parsed.explanation || '',
        sql: parsed.sql || null,
        viewName: parsed.viewName || null,
        data,
        queryError,
        chartSuggestion: parsed.chartSuggestion || null,
      }
    });
  } catch (err) {
    // Prefer API error body (OpenAI returns err.response?.data?.error?.message)
    const apiError = err.response?.data?.error?.message || err.response?.data?.error;
    const msg = (typeof apiError === 'string' ? apiError : null) || err.message || 'Chat failed';
    console.error('[Finnie chat]', err.response?.status || '', msg, err.response?.data ? '(see below)' : '');
    if (err.response?.data) console.error('[Finnie chat] API response:', JSON.stringify(err.response.data, null, 2));

    // Friendly messages for common errors
    if (msg.includes('429') || msg.includes('rate_limit') || msg.includes('Too Many Requests')) {
      return res.status(429).json({ error: 'Rate limit reached. Wait a moment and try again.' });
    }
    if (err.response?.status === 401 || msg.includes('401') || msg.includes('invalid_api_key') || msg.includes('Unauthorized') || msg.includes('Incorrect API key')) {
      const provider = (process.env.LLM_PROVIDER || 'groq').toLowerCase();
      return res.status(401).json({
        error: (provider === 'openai' ? 'OpenAI' : 'Groq') + ' API key is invalid or expired. Check ' + (provider === 'openai' ? 'OPENAI_API_KEY' : 'GROQ_API_KEY') + ' in .env. Get a key at platform.openai.com or console.groq.com.',
      });
    }
    if (err.response?.status === 404 || msg.includes('404') || (msg.includes('model') && (msg.includes('not found') || msg.includes('does not exist')))) {
      return res.status(400).json({ error: 'Invalid model. In .env set OPENAI_MODEL to gpt-4o-mini or gpt-4o (or use Groq: LLM_PROVIDER=groq and GROQ_MODEL=llama-3.3-70b-versatile).' });
    }
    // Connection/network errors — often firewall, proxy, or DNS
    if (msg.includes('Connection error') || msg.includes('ECONNREFUSED') || msg.includes('ECONNRESET') || msg.includes('ETIMEDOUT') || msg.includes('fetch failed') || msg.includes('ENOTFOUND')) {
      const provider = (process.env.LLM_PROVIDER || 'groq').toLowerCase();
      return res.status(502).json({
        error: 'Cannot reach ' + (provider === 'openai' ? 'OpenAI' : 'Groq') + ' API. Check internet/VPN/firewall. Try LLM_PROVIDER=groq with GROQ_API_KEY if OpenAI is blocked.',
      });
    }
    res.status(500).json({ error: msg });
  }
});

// SPA fallback
app.get('*', (req, res) => {
  const distIndex = path.join(distPath, 'index.html');
  const publicIndex = path.join(publicPath, 'index.html');
  if (fs.existsSync(distIndex)) res.sendFile(distIndex);
  else if (fs.existsSync(publicIndex)) res.sendFile(publicIndex);
  else res.status(404).send('No UI found. Run npm run build or add public/index.html');
});

const server = http.createServer(app);
server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`\nPort ${PORT} is already in use. Either:\n  - Stop the other process using port ${PORT}, or\n  - Set a different PORT in .env (e.g. PORT=4001)\n`);
    process.exit(1);
  }
  throw err;
});
server.listen(PORT, () => {
  console.log(`CDS Query UI server at http://localhost:${PORT}`);
  console.log(`CDS views path: ${getCdsBasePath()}`);
});
