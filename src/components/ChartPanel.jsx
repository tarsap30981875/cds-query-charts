import React, { useMemo } from 'react';
import './ChartPanel.css';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  AreaChart,
  Area,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';

const CHART_TYPES = ['bar', 'line', 'pie', 'area'];
const COLORS = ['#00c9b7', '#5c7cfa', '#f59f00', '#ec4899', '#10b981', '#6366f1'];

export default function ChartPanel({ columns, rows, chartConfig, onConfigChange }) {
  const { type = 'bar', xKey = '', yKeys = [] } = chartConfig;

  const numericColumns = useMemo(() => columns.filter((col) => {
    if (!rows.length) return false;
    const val = rows[0][col];
    return val !== undefined && (typeof val === 'number' || !Number.isNaN(Number(val)));
  }), [columns, rows]);

  const allKeys = useMemo(() => {
    const first = rows[0];
    if (!first) return columns;
    return columns.filter((col) => first[col] !== undefined);
  }, [columns, rows]);

  const chartData = useMemo(() => {
    if (!rows.length) return [];
    return rows.map((row) => {
      const point = { ...row };
      allKeys.forEach((k) => {
        const v = row[k];
        if (v !== undefined && v !== null && typeof v !== 'number') point[k] = Number(v) ?? v;
      });
      return point;
    });
  }, [rows, allKeys]);

  const setConfig = (patch) => onConfigChange({ ...chartConfig, ...patch });

  if (!columns.length || !rows.length) {
    return (
      <div className="chart-empty">
        Run a query and load results to build a chart. Then choose chart type, X axis, and one or more measures.
      </div>
    );
  }

  const xOptions = allKeys;
  const yOptions = numericColumns.length ? numericColumns : allKeys;

  return (
    <div className="chart-panel-inner">
      <div className="chart-controls">
        <div className="field inline">
          <label>Type</label>
          <select value={type} onChange={(e) => setConfig({ type: e.target.value })} className="input select">
            {CHART_TYPES.map((t) => (
              <option key={t} value={t}>{t}</option>
            ))}
          </select>
        </div>
        <div className="field inline">
          <label>X axis</label>
          <select value={xKey} onChange={(e) => setConfig({ xKey: e.target.value })} className="input select">
            <option value="">—</option>
            {xOptions.map((c) => (
              <option key={c} value={c}>{c}</option>
            ))}
          </select>
        </div>
        <div className="field">
          <label>Y (measures) — pick one or more</label>
          <div className="y-keys-chips">
            {yOptions.map((c) => (
              <label key={c} className="chip">
                <input
                  type="checkbox"
                  checked={yKeys.includes(c)}
                  onChange={(e) => {
                    const next = e.target.checked ? [...yKeys, c] : yKeys.filter((k) => k !== c);
                    setConfig({ yKeys: next });
                  }}
                />
                <span>{c}</span>
              </label>
            ))}
          </div>
        </div>
      </div>

      <div className="chart-container">
        {(!xKey || !yKeys.length) ? (
          <div className="chart-placeholder">Select X axis and at least one measure.</div>
        ) : (
          <ResponsiveContainer width="100%" height={320}>
            {type === 'pie' ? (
              <PieChart>
                <Pie
                  data={chartData}
                  dataKey={yKeys[0]}
                  nameKey={xKey}
                  cx="50%"
                  cy="50%"
                  outerRadius="70%"
                  label={({ [xKey]: name, [yKeys[0]]: value }) => `${name ?? ''}: ${value}`}
                >
                  {chartData.map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            ) : type === 'area' ? (
              <AreaChart data={chartData} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                <XAxis dataKey={xKey} stroke="var(--text-secondary)" fontSize={11} />
                <YAxis stroke="var(--text-secondary)" fontSize={11} />
                <Tooltip contentStyle={{ background: 'var(--bg-card)', border: '1px solid var(--border)' }} />
                <Legend />
                {yKeys.map((key, i) => (
                  <Area key={key} type="monotone" dataKey={key} stroke={COLORS[i % COLORS.length]} fill={COLORS[i % COLORS.length]} fillOpacity={0.35} strokeWidth={2} />
                ))}
              </AreaChart>
            ) : type === 'line' ? (
              <LineChart data={chartData} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                <XAxis dataKey={xKey} stroke="var(--text-secondary)" fontSize={11} />
                <YAxis stroke="var(--text-secondary)" fontSize={11} />
                <Tooltip contentStyle={{ background: 'var(--bg-card)', border: '1px solid var(--border)' }} />
                <Legend />
                {yKeys.map((key, i) => (
                  <Line key={key} type="monotone" dataKey={key} stroke={COLORS[i % COLORS.length]} strokeWidth={2} dot={false} />
                ))}
              </LineChart>
            ) : (
              <BarChart data={chartData} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                <XAxis dataKey={xKey} stroke="var(--text-secondary)" fontSize={11} />
                <YAxis stroke="var(--text-secondary)" fontSize={11} />
                <Tooltip contentStyle={{ background: 'var(--bg-card)', border: '1px solid var(--border)' }} />
                <Legend />
                {yKeys.map((key, i) => (
                  <Bar key={key} dataKey={key} fill={COLORS[i % COLORS.length]} radius={[4, 4, 0, 0]} />
                ))}
              </BarChart>
            )}
          </ResponsiveContainer>
        )}
      </div>
    </div>
  );
}
