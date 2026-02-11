import React from 'react';
import './ConnectionStatus.css';

export default function ConnectionStatus({ connected, onRetry }) {
  return (
    <div className="connection-status">
      {connected === null ? (
        <span className="status status-pending">Checking connection…</span>
      ) : connected ? (
        <span className="status status-ok">● Connected</span>
      ) : (
        <span className="status status-fail">
          ● Not connected
          <button type="button" className="btn-retry" onClick={onRetry}>
            Retry
          </button>
        </span>
      )}
    </div>
  );
}
