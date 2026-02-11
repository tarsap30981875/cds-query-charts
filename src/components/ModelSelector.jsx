import React from 'react';
import './ModelSelector.css';

export default function ModelSelector({
  views,
  selectedView,
  onSelect,
  queryMode,
  onModeChange,
  customSql,
  onCustomSqlChange,
}) {
  return (
    <div className="model-selector">
      <div className="mode-tabs">
        <button
          type="button"
          className={queryMode === 'tableContents' ? 'active' : ''}
          onClick={() => onModeChange('tableContents')}
        >
          CDS View
        </button>
        <button
          type="button"
          className={queryMode === 'runQuery' ? 'active' : ''}
          onClick={() => onModeChange('runQuery')}
        >
          Custom SQL
        </button>
      </div>

      {queryMode === 'tableContents' ? (
        <div className="field">
          <label>CDS model</label>
          <select
            value={selectedView}
            onChange={(e) => onSelect(e.target.value)}
            className="input select"
          >
            <option value="">Select a view…</option>
            {views.map((v) => (
              <option key={v} value={v}>{v}</option>
            ))}
          </select>
        </div>
      ) : (
        <div className="field">
          <label>SQL (e.g. SELECT * FROM view_name)</label>
          <textarea
            value={customSql}
            onChange={(e) => onCustomSqlChange(e.target.value)}
            placeholder="SELECT * FROM ZFIN_I_BILLRATE_V"
            className="input textarea mono"
            rows={4}
          />
        </div>
      )}
    </div>
  );
}
