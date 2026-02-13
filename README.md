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
   - `SAP_URL` — your SAP system URL
   - `SAP_USER` — SAP username
   - `SAP_PASSWORD` — SAP password
   - `GROQ_API_KEY` — Groq API key (free at console.groq.com)
6. Deploy!

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
| `CDS_SOURCE_PATH` | No | `./cds-views` | Path to `.ddls.abap` files |
| `PORT` | No | `3001` | Server port |

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
