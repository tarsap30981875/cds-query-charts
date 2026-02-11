import React from 'react';
import './QueryPanel.css';

export default function QueryPanel({ rowLimit, setRowLimit, decode, setDecode, onRun, loading, disabled }) {
  return (
    <div className="query-panel-actions">
      <div className="options">
        <div className="field inline">
          <label>Max rows</label>
          <input
            type="number"
            min={1}
            max={10000}
            value={rowLimit}
            onChange={(e) => setRowLimit(Number(e.target.value) || 500)}
            className="input number"
          />
        </div>
        <label className="checkbox-label">
          <input type="checkbox" checked={decode} onChange={(e) => setDecode(e.target.checked)} />
          Decode values
        </label>
      </div>
      <button
        type="button"
        className="btn-run"
        onClick={onRun}
        disabled={disabled || loading}
      >
        {loading ? 'Running…' : 'Run query'}
      </button>
    </div>
  );
}
