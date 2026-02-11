/**
 * CDS Query UI – Backend
 * Express API that uses abap-adt-api to run queries and list CDS views.
 */
import 'dotenv/config';
import path from 'path';
import { fileURLToPath } from 'url';
import express from 'express';
import cors from 'cors';
import { ADTClient, createSSLConfig } from 'abap-adt-api';
import OpenAI from 'openai';
import fs from 'fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CDS_EXT = '.ddls.abap';

// ─── SAP ADT client (lazy init) ─────────────────────────────────────
let adtClient = null;

function getAdtClient() {
  if (adtClient) return adtClient;
  const missing = ['SAP_URL', 'SAP_USER', 'SAP_PASSWORD'].filter((k) => !process.env[k]);
  if (missing.length) throw new Error(`Missing env: ${missing.join(', ')}`);
  adtClient = new ADTClient(
    process.env.SAP_URL,
    process.env.SAP_USER,
    process.env.SAP_PASSWORD,
    process.env.SAP_CLIENT || '100',
    process.env.SAP_LANGUAGE || 'EN',
    createSSLConfig(true)
  );
  adtClient.stateful = 'stateful';
  return adtClient;
}

// ─── Local CDS view list (from zanalytics-cds) ───────────────────────
function listLocalCdsViews() {
  const basePath = path.resolve(process.env.CDS_SOURCE_PATH || path.join(__dirname, '..', 'cds-views'));
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

// ─── API: Connection check ──────────────────────────────────────────
app.get('/api/connection', async (req, res) => {
  try {
    const client = getAdtClient();
    await client.reentranceTicket();
    res.json({ ok: true, message: 'Connected' });
  } catch (err) {
    res.status(503).json({ ok: false, message: err.message || 'Connection failed' });
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
    const client = getAdtClient();
    const { type, ddicEntityName, sqlQuery, rowNumber = 500, decode = true } = req.body;

    if (type === 'tableContents') {
      if (!ddicEntityName) return res.status(400).json({ error: 'ddicEntityName required' });
      const result = await client.tableContents(ddicEntityName, rowNumber, decode, sqlQuery || undefined);
      return res.json({ status: 'success', result });
    }

    if (type === 'runQuery') {
      if (!sqlQuery) return res.status(400).json({ error: 'sqlQuery required' });
      const result = await client.runQuery(sqlQuery, rowNumber, decode);
      return res.json({ status: 'success', result });
    }

    res.status(400).json({ error: 'Invalid type; use tableContents or runQuery' });
  } catch (err) {
    res.status(500).json({ error: err.message || 'Query failed' });
  }
});

// ─── OpenAI client (lazy) ────────────────────────────────────────────
let openaiClient = null;
function getOpenAI() {
  if (openaiClient) return openaiClient;
  if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY.startsWith('sk-PASTE'))
    throw new Error('OPENAI_API_KEY not configured in .env');
  openaiClient = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  return openaiClient;
}

// Read CDS view sources for AI context
function readCdsViewSource(viewName) {
  const basePath = path.resolve(process.env.CDS_SOURCE_PATH || path.join(__dirname, '..', 'cds-views'));
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

// ─── API: Chat (NLP to SQL) ──────────────────────────────────────────
app.post('/api/chat', async (req, res) => {
  try {
    const { message, history = [] } = req.body;
    if (!message) return res.status(400).json({ error: 'message required' });

    const ai = getOpenAI();
    const model = process.env.OPENAI_MODEL || 'gpt-4o';
    const cdsContext = buildCdsContext();
    const systemMsg = SYSTEM_PROMPT.replace('{CDS_CONTEXT}', cdsContext);

    // Build conversation
    const messages = [
      { role: 'system', content: systemMsg },
      ...history.slice(-10).map(m => ({ role: m.role, content: m.content })),
      { role: 'user', content: message }
    ];

    const completion = await ai.chat.completions.create({
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
    res.status(500).json({ error: err.message || 'Chat failed' });
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

app.listen(PORT, () => {
  console.log(`CDS Query UI server at http://localhost:${PORT}`);
  console.log(`CDS views path: ${process.env.CDS_SOURCE_PATH || path.join(__dirname, '..', 'cds-views')}`);
});
