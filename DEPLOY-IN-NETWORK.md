# Deploy Ask Finnie inside your network

Run the app on a server that can reach your SAP system (same network or VPN) so SAP connection works. Then share the internal URL with your team.

---

## Option A: Docker (recommended)

Use on any in-network machine with Docker (Windows Server, Linux, or VM with VPN).

### 1. Build the image

From this repo root (e.g. after cloning or copying the project):

```bash
cd cds-query-ui
docker build -t ask-finnie .
```

### 2. Create a `.env` file on the server

Copy `.env.example` to `.env` and set your SAP and LLM values:

- `SAP_URL`, `SAP_USER`, `SAP_PASSWORD`, `SAP_CLIENT`, `SAP_LANGUAGE`
- `LLM_PROVIDER=groq` and `GROQ_API_KEY=...` (or `openai` and `OPENAI_API_KEY`)
- `PORT=4000`

### 3. Run the container

**With env file (no CDS view dropdown):**

```bash
docker run -d --name ask-finnie -p 4000:4000 --env-file .env ask-finnie
```

**With env file + CDS view files (mount folder with `.ddls.abap` files):**

```bash
docker run -d --name ask-finnie -p 4000:4000 --env-file .env \
  -e CDS_SOURCE_PATH=/app/cds-views \
  -v /path/on/host/to/zanalytics-cds:/app/cds-views:ro \
  ask-finnie
```

Replace `/path/on/host/to/zanalytics-cds` with the real path to your CDS view folder on the server.

### 4. Share the app

- From the same machine: open **http://localhost:4000**
- From other PCs on the network: open **http://\<this-server-ip\>:4000** (e.g. `http://10.0.1.50:4000`)

To find the server IP: `ipconfig` (Windows) or `ip addr` (Linux).

---

## Option B: Node.js directly (no Docker)

Use on a Windows or Linux server that has Node.js 18+ and can reach SAP.

### 1. Clone or copy the project onto the server

```bash
git clone https://github.com/tarsap30981875/cds-query-charts.git cds-query-ui
cd cds-query-ui
```

(Or copy the project folder from your PC.)

### 2. Install and configure

```bash
npm install
cp .env.example .env
# Edit .env with SAP_URL, SAP_USER, SAP_PASSWORD, and LLM keys (GROQ or OpenAI)
```

Optional: copy your CDS view files (e.g. `zanalytics-cds` folder) so the dropdown is populated, and set `CDS_SOURCE_PATH` in `.env` to that path.

### 3. Run the server

**One-off (stops when you close the terminal):**

```bash
npm start
```

**Keep it running in the background (Linux with PM2):**

```bash
npm install -g pm2
pm2 start server/index.js --name ask-finnie
pm2 save
pm2 startup   # optional: start on reboot
```

**Windows (run in background):** Start a process in the background or use a scheduled task / Windows Service wrapper.

### 4. Share the app

- Same machine: **http://localhost:4000**
- Other PCs: **http://\<server-ip\>:4000**

Open Windows Firewall (or equivalent) for port **4000** if others need to connect.

---

## Option C: Windows server (quick run)

1. Copy the whole `cds-query-ui` folder to the server.
2. Install Node.js 18+ from [nodejs.org](https://nodejs.org).
3. In the folder, run:
   - `npm install`
   - Copy `.env.example` to `.env`, edit with your SAP and LLM settings.
   - `npm start`
4. Open **http://localhost:4000** on the server, or **http://\<server-ip\>:4000** from other PCs.
5. To keep it running after logout, use a tool like **pm2-windows-service** or **NSSM**, or run it as a scheduled task.

---

## Checklist

| Step | Done |
|------|------|
| Server can reach SAP (same network or VPN) | ☐ |
| Node.js 18+ (or Docker) installed | ☐ |
| `.env` has SAP_URL, SAP_USER, SAP_PASSWORD, LLM key | ☐ |
| App starts (`npm start` or `docker run`) | ☐ |
| Port 4000 open in firewall if others will connect | ☐ |
| Shared URL: `http://<server-ip>:4000` | ☐ |

---

## Troubleshooting

- **"SAP: Not connected"** — From the server, test: `curl -k "https://YOUR_SAP_HOST:PORT/sap/bc/adt/compatibility/graph"` (or use a browser). If that fails, the server cannot reach SAP (VPN, firewall, or DNS).
- **Port 4000 in use** — Set `PORT=4001` in `.env` and use 4001 in the URL.
- **CDS dropdown empty** — Set `CDS_SOURCE_PATH` to a folder that contains `.ddls.abap` files on the server (or mount that folder in Docker).
