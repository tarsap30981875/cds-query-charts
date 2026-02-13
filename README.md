# Ask Finnie — SAP Analytics & Insights

**Ask Finnie** is a professional web application that lets you **connect** to SAP S/4, **query CDS models** using natural language or SQL, and **generate interactive charts** from the results — all powered by AI.

![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=nodedotjs&logoColor=white)
![Express](https://img.shields.io/badge/Express-4-000000?logo=express&logoColor=white)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=black)
![Recharts](https://img.shields.io/badge/Recharts-2-22b5bf)
![Groq](https://img.shields.io/badge/Groq-Llama_3.3_70B-f55036?logo=meta&logoColor=white)

## Features

- **Ask Finnie (AI Chat)** — query your SAP data in plain English; Finnie uses Groq (Llama 3.3 70B) to generate SQL, runs it, and suggests charts
- **Live connection status** to SAP S/4 system
- **CDS model selector** — pick from the bundled views, or switch to **Custom SQL**
- **Configurable query** — max rows, decode toggle
- **Results table** — scrollable grid with sticky headers
- **Charts** — Bar, Line, Area, Pie with configurable X/Y axes
- **Dark theme** — modern design with teal accent

## One-Click Deploy to Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/tarsap30981875/cds-query-charts)

Click the button above, then set the required environment variables in the Render dashboard.

**Groq unreachable?** (e.g. corporate firewall) — In `.env` set `LLM_PROVIDER=openai`, add `OPENAI_API_KEY=sk-...`, then restart. Ask Finnie will use OpenAI instead.

## Quick Start (local)

```bash
cp .env.example .env
# Edit .env with your SAP credentials and LLM API key
npm install
npm start
# Open http://localhost:4000
```

**Port 4000 already in use?** The server will print a clear message. Either stop the other process using port 4000, or set `PORT=4001` (or another free port) in `.env`. On Windows, to free the port: `netstat -ano | findstr :4000` then `taskkill /PID <pid> /F`.

## Deploy to Render (free)

1. Push this repo to GitHub
2. Go to [render.com](https://render.com) → New → **Web Service**
3. Connect the GitHub repo
4. Render detects `render.yaml` automatically
5. Set **environment variables** in the Render dashboard:
   - `SAP_URL` — your SAP system URL (see **Render + SAP** below if connection fails)
   - `SAP_USER` — SAP username
   - `SAP_PASSWORD` — SAP password
   - `OPENAI_API_KEY` or `GROQ_API_KEY` — for Ask Finnie chat
6. Deploy!

### Render + SAP connection

**If the app on Render shows "SAP: Not connected"** — Render runs in the **cloud**. Your SAP system (e.g. `s4hnpn.sap.mckinsey.com`) is usually **on-premise or behind a corporate firewall**, so Render’s servers **cannot reach it** (connection refused or timeout).

**Options:**

| Option | When to use |
|--------|-------------|
| **Deploy inside your network** | Run the app on a server that can reach SAP (e.g. a VM or container with VPN, or on the same network as SAP). Build and run with `npm install && npm start`, then share the internal URL. |
| **Expose SAP to the internet** | If your security policy allows, make the SAP system reachable from the internet (e.g. via reverse proxy / DMZ). Then set `SAP_URL` on Render to that public URL. |
| **Use Render for UI only** | Deploy on Render for the shareable UI; SAP features will show "Not connected." Use Ask Finnie (LLM) and Custom SQL only when you run the app locally with SAP credentials. |

**Quick fix for a shareable demo without SAP:** Deploy on Render as-is. The app will still load; only the SAP connection will fail. You can document that "SAP queries work when run locally; on Render the app is for UI/demo."

**To get SAP working with a shareable URL:** Deploy the app **inside your network** (server with VPN or same network as SAP). See **[DEPLOY-IN-NETWORK.md](DEPLOY-IN-NETWORK.md)** for step-by-step instructions (Docker, Node.js, or Windows server).

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SAP_URL` | Yes | — | SAP S/4 system URL (e.g. `https://host:44300`) |
| `SAP_USER` | Yes | — | SAP username |
| `SAP_PASSWORD` | Yes | — | SAP password |
| `SAP_CLIENT` | No | `100` | SAP client number |
| `SAP_LANGUAGE` | No | `EN` | SAP language |
| `LLM_PROVIDER` | No | `groq` | `groq` or `openai` — use `openai` if Groq is blocked by firewall |
| `GROQ_API_KEY` | Yes* | — | Groq API key (free at [console.groq.com](https://console.groq.com)) |
| `GROQ_MODEL` | No | `llama-3.3-70b-versatile` | Groq model |
| `OPENAI_API_KEY` | Yes* | — | Required when `LLM_PROVIDER=openai` |
| `OPENAI_MODEL` | No | `gpt-4o-mini` | OpenAI model when using OpenAI |
| `OPENAI_API_BASE` | No | — | Optional custom base URL (e.g. Azure, OpenRouter) |
| `CDS_SOURCE_PATH` | No | `./cds-views` | Path to `.ddls.abap` files (on Render use `./cds-views` or leave default) |
| `PORT` | No | `3001` | Server port (Render sets this automatically) |

## API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/connection` | GET | Check SAP connectivity |
| `/api/cds-views` | GET | List available CDS view names |
| `/api/query` | POST | Run a query (see body format below) |
| `/api/chat` | POST | NLP chat — natural language to SQL via Gemini |

**POST /api/query** body:
```json
{ "type": "tableContents", "ddicEntityName": "ZFIN_I_BILLRATE_V", "rowNumber": 500, "decode": true }
```
or:
```json
{ "type": "runQuery", "sqlQuery": "SELECT * FROM ZFIN_I_BILLRATE_V", "rowNumber": 500, "decode": true }
```

**POST /api/chat** body:
```json
{ "message": "Show me all bill rates", "history": [] }
```

## Tech Stack

- **Backend:** Express, `abap-adt-api`, `openai` SDK (Groq-compatible)
- **Frontend:** React 18 (CDN, no build step), Recharts
- **AI:** Groq — Llama 3.3 70B (free tier: 30 req/min, 14,400 req/day)
- **Design:** Dark theme, DM Sans + JetBrains Mono

---
Built with UI Agent
