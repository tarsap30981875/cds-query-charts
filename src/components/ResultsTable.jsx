import React from 'react';
import './ResultsTable.css';

function normalizeResult(result) {
  if (!result) return { columns: [], rows: [] };
  if (Array.isArray(result)) return { columns: [], rows: result };
  const cols = result.columns ?? result.COLUMNS ?? [];
  const colNames = Array.isArray(cols) ? cols.map((c) => (typeof c === 'string' ? c : c?.name ?? '')) : [];
  let rows = result.rows ?? result.values ?? result.RESULT ?? result.result ?? [];
  if (Array.isArray(rows) && rows.length && Array.isArray(rows[0]) && colNames.length) {
    rows = rows.map((rowArr) => colNames.reduce((obj, name, i) => ({ ...obj, [name]: rowArr[i] }), {}));
  }
  if (!colNames.length && rows[0] && typeof rows[0] === 'object' && !Array.isArray(rows[0])) colNames.push(...Object.keys(rows[0]));
  return { columns: colNames, rows: Array.isArray(rows) ? rows : [] };
}

export default function ResultsTable({ columns: colProp, rows: rowProp, loading }) {
  const { columns, rows } = normalizeResult(colProp?.length >= 0 ? { columns: colProp, rows: rowProp } : null);
  const safeColumns = columns.length ? columns : (rows[0] ? Object.keys(rows[0]) : []);

  if (loading) {
    return (
      <div className="results-loading">
        <div className="spinner" />
        <span>Loading…</span>
      </div>
    );
  }

  if (!safeColumns.length && !rows.length) {
    return (
      <div className="results-empty">
        Run a query to see results here.
      </div>
    );
  }

  return (
    <div className="results-wrap">
      <div className="results-table-scroll">
        <table className="results-table">
          <thead>
            <tr>
              {safeColumns.map((col) => (
                <th key={col}>{String(col)}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row, i) => (
              <tr key={i}>
                {safeColumns.map((col) => (
                  <td key={col}>{row[col] != null ? String(row[col]) : '—'}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="results-meta">{rows.length} row{rows.length !== 1 ? 's' : ''}</div>
    </div>
  );
}
