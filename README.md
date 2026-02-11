# CDS Query & Charts

A professional web UI to **connect** to SAP S/4, **query CDS models**, and **generate interactive charts** from the results.

![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=nodedotjs&logoColor=white)
![Express](https://img.shields.io/badge/Express-4-000000?logo=express&logoColor=white)
![React](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=black)
![Recharts](https://img.shields.io/badge/Recharts-2-22b5bf)

## Features

- **Live connection status** to SAP S/4 system
- **CDS model selector** — pick from the bundled views, or switch to **Custom SQL**
- **Configurable query** — max rows, decode toggle
- **Results table** — scrollable grid with sticky headers
- **Charts** — Bar, Line, Area, Pie with configurable X/Y axes
- **Dark theme** — modern design with teal accent

## One-Click Deploy to Render

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/tarsap30981875/cds-query-charts)

Click the button above, then set the three required environment variables (`SAP_URL`, `SAP_USER`, `SAP_PASSWORD`) in the Render dashboard.

## Quick Start (local)

```bash
cp .env.example .env
# Edit .env with your SAP credentials
npm install
npm start
# Open http://localhost:4000
```

## Deploy to Render (free)

1. Push this repo to GitHub
2. Go to [render.com](https://render.com) → New → **Web Service**
3. Connect the GitHub repo
4. Render detects `render.yaml` automatically
5. Set **environment variables** in the Render dashboard:
   - `SAP_URL` — your SAP system URL
   - `SAP_USER` — SAP username
   - `SAP_PASSWORD` — SAP password
6. Deploy!

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SAP_URL` | Yes | — | SAP S/4 system URL (e.g. `https://host:44300`) |
| `SAP_USER` | Yes | — | SAP username |
| `SAP_PASSWORD` | Yes | — | SAP password |
| `SAP_CLIENT` | No | `100` | SAP client number |
| `SAP_LANGUAGE` | No | `EN` | SAP language |
| `CDS_SOURCE_PATH` | No | `./cds-views` | Path to `.ddls.abap` files |
| `PORT` | No | `3001` | Server port |

## API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/connection` | GET | Check SAP connectivity |
| `/api/cds-views` | GET | List available CDS view names |
| `/api/query` | POST | Run a query (see body format below) |

**POST /api/query** body:
```json
{ "type": "tableContents", "ddicEntityName": "ZFIN_I_BILLRATE_V", "rowNumber": 500, "decode": true }
```
or:
```json
{ "type": "runQuery", "sqlQuery": "SELECT * FROM ZFIN_I_BILLRATE_V", "rowNumber": 500, "decode": true }
```

## Tech Stack

- **Backend:** Express, `abap-adt-api`
- **Frontend:** React 19 (CDN, no build step), Recharts
- **Design:** Dark theme, DM Sans + JetBrains Mono

---
Built with UI Agent
