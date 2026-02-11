import React, { useState, useEffect, useCallback } from 'react';
import ConnectionStatus from './components/ConnectionStatus';
import ModelSelector from './components/ModelSelector';
import QueryPanel from './components/QueryPanel';
import ResultsTable from './components/ResultsTable';
import ChartPanel from './components/ChartPanel';
import './App.css';

export default function App() {
  const [connected, setConnected] = useState(null);
  const [cdsViews, setCdsViews] = useState([]);
  const [selectedView, setSelectedView] = useState('');
  const [queryMode, setQueryMode] = useState('tableContents');
  const [customSql, setCustomSql] = useState('');
  const [rowLimit, setRowLimit] = useState(500);
  const [decode, setDecode] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [result, setResult] = useState(null);
  const [chartConfig, setChartConfig] = useState({ type: 'bar', xKey: '', yKeys: [] });

  const checkConnection = useCallback(async () => {
    setConnected(null);
    try {
      const r = await fetch('/api/connection');
      const data = await r.json().catch(() => ({}));
      setConnected(data.ok === true);
    } catch {
      setConnected(false);
    }
  }, []);

  const loadCdsViews = useCallback(async () => {
    try {
      const r = await fetch('/api/cds-views');
      const data = await r.json();
      setCdsViews(data.views || []);
      if (data.views?.length && !selectedView) setSelectedView(data.views[0]);
    } catch {
      setCdsViews([]);
    }
  }, [selectedView]);

  useEffect(() => {
    checkConnection();
    loadCdsViews();
  }, [checkConnection, loadCdsViews]);

  const runQuery = async () => {
    setError(null);
    setResult(null);
    setLoading(true);
    try {
      const body =
        queryMode === 'tableContents'
          ? { type: 'tableContents', ddicEntityName: selectedView, rowNumber: rowLimit, decode }
          : { type: 'runQuery', sqlQuery: customSql, rowNumber: rowLimit, decode };
      const r = await fetch('/api/query', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      const data = await r.json();
      if (!r.ok) throw new Error(data.error || 'Query failed');
      setResult(data.result);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  const colNames = !result ? [] : (Array.isArray(result.columns)
    ? result.columns.map((c) => (typeof c === 'string' ? c : c?.name ?? ''))
    : result.rows?.[0] && typeof result.rows[0] === 'object' ? Object.keys(result.rows[0]) : []);
  const rawVals = result?.values ?? result?.rows ?? (Array.isArray(result) ? result : []);
  const rows = !Array.isArray(rawVals) ? [] : (rawVals[0] && Array.isArray(rawVals[0])
    ? rawVals.map((arr) => (result.columns || []).reduce((o, c, i) => ({ ...o, [typeof c === 'string' ? c : c?.name ?? '']: arr[i] }), {}))
    : rawVals);
  const columns = colNames.length ? colNames : (rows[0] ? Object.keys(rows[0]) : []);

  return (
    <div className="app">
      <header className="app-header">
        <div className="brand">
          <span className="brand-icon">◇</span>
          <h1>CDS Query & Charts</h1>
        </div>
        <ConnectionStatus connected={connected} onRetry={checkConnection} />
      </header>

      <main className="app-main">
        <section className="panel query-panel">
          <h2>Query</h2>
          <ModelSelector
            views={cdsViews}
            selectedView={selectedView}
            onSelect={setSelectedView}
            queryMode={queryMode}
            onModeChange={setQueryMode}
            customSql={customSql}
            onCustomSqlChange={setCustomSql}
          />
          <QueryPanel
            rowLimit={rowLimit}
            setRowLimit={setRowLimit}
            decode={decode}
            setDecode={setDecode}
            onRun={runQuery}
            loading={loading}
            disabled={queryMode === 'tableContents' ? !selectedView : !customSql.trim()}
          />
          {error && <div className="error-msg">{error}</div>}
        </section>

        <section className="panel results-panel">
          <h2>Results</h2>
          <ResultsTable columns={columns} rows={rows} loading={loading} />
        </section>

        <section className="panel chart-panel">
          <h2>Charts</h2>
          <ChartPanel
            columns={columns}
            rows={rows}
            chartConfig={chartConfig}
            onConfigChange={setChartConfig}
          />
        </section>
      </main>
    </div>
  );
}
