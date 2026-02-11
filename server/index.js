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
