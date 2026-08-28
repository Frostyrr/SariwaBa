import React, { useState } from 'react';
import {
  BarChart3,
  Download,
  Calendar,
  Eye,
  Sparkles,
  Layers,
  CheckCircle2,
  AlertTriangle,
  XCircle,
} from 'lucide-react';

export const Analytics: React.FC = () => {
  const [timeRange, setTimeRange] = useState<'today' | 'week' | 'month'>('week');

  const weeklyTraffic = [
    { day: 'Mon', count: 980, fresh: 720, spoiled: 80 },
    { day: 'Tue', count: 1140, fresh: 860, spoiled: 90 },
    { day: 'Wed', count: 1320, fresh: 990, spoiled: 110 },
    { day: 'Thu', count: 1250, fresh: 940, spoiled: 95 },
    { day: 'Fri', count: 1540, fresh: 1180, spoiled: 140 },
    { day: 'Sat', count: 1890, fresh: 1420, spoiled: 190 },
    { day: 'Sun', count: 1429, fresh: 1060, spoiled: 142 },
  ];

  const speciesStats = [
    {
      name: 'Bangus (Milkfish)',
      total: 512,
      freshPercent: 88,
      moderatePercent: 8,
      spoiledPercent: 4,
      score: 9.4,
    },
    {
      name: 'Galunggong (Round Scad)',
      total: 384,
      freshPercent: 79,
      moderatePercent: 14,
      spoiledPercent: 7,
      score: 8.6,
    },
    {
      name: 'Tilapia',
      total: 265,
      freshPercent: 72,
      moderatePercent: 19,
      spoiledPercent: 9,
      score: 8.1,
    },
    {
      name: 'Tambakol (Yellowfin Tuna)',
      total: 158,
      freshPercent: 64,
      moderatePercent: 21,
      spoiledPercent: 15,
      score: 7.4,
    },
    {
      name: 'Maya-Maya (Red Snapper)',
      total: 110,
      freshPercent: 92,
      moderatePercent: 5,
      spoiledPercent: 3,
      score: 9.6,
    },
  ];

  const sensoryMetrics = [
    {
      name: 'Eye Cornea & Pupil Clarity',
      accuracy: '96.8%',
      description: 'Specular reflectivity, opacity, and convex shape detection.',
      score: 96.8,
    },
    {
      name: 'Gill Redness & Pigment Spectrum',
      accuracy: '94.2%',
      description: 'RGB/HSV chromatic analysis for blood oxygenation and decay.',
      score: 94.2,
    },
    {
      name: 'Flesh Texture & Scale Tightness',
      accuracy: '91.5%',
      description: 'Surface elasticity contouring and scale sheen reflectance.',
      score: 91.5,
    },
  ];

  return (
    <div className="space-y-8">
      {/* Header Bar */}
      <div className="bg-white rounded-3xl border border-slate-200 p-6 sm:p-8 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-2">
            <BarChart3 size={13} />
            <span>Telemetry & Insights</span>
          </div>
          <h1 className="font-heading font-black text-2xl sm:text-3xl text-slate-950 uppercase tracking-tight">
            Classification Analytics
          </h1>
          <p className="font-sans text-xs sm:text-sm text-slate-500 mt-1">
            Statistical breakdown of quality scores, species volume, and sensory model precision.
          </p>
        </div>

        {/* Controls */}
        <div className="flex items-center gap-3">
          <div className="inline-flex p-1 rounded-2xl bg-slate-100 border border-slate-200 text-xs font-bold uppercase tracking-wider">
            {(['today', 'week', 'month'] as const).map((range) => (
              <button
                key={range}
                onClick={() => setTimeRange(range)}
                className={`px-3.5 py-1.5 rounded-xl transition-all cursor-pointer ${
                  timeRange === range
                    ? 'bg-white text-slate-950 shadow-xs'
                    : 'text-slate-500 hover:text-slate-900'
                }`}
              >
                {range}
              </button>
            ))}
          </div>

          <button className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-2xl bg-[#0066ff] hover:bg-blue-600 text-white font-heading text-xs font-bold uppercase tracking-wider transition-colors cursor-pointer shadow-xs">
            <Download size={14} />
            <span>Export CSV</span>
          </button>
        </div>
      </div>

      {/* Grid: Scan Volume & Overall Grade Distribution */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        
        {/* Weekly Scan Volume Bar Visualizer */}
        <div className="lg:col-span-8 bg-white rounded-3xl border border-slate-200 p-6 sm:p-7 shadow-xs">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="font-heading font-black text-lg text-slate-950 uppercase tracking-tight">
                Scan Volume Trends
              </h2>
              <p className="font-sans text-xs text-slate-500">Weekly classification throughput across all stations</p>
            </div>
            <div className="flex items-center gap-3 text-xs font-semibold text-slate-500">
              <span className="flex items-center gap-1.5">
                <span className="w-2.5 h-2.5 rounded-full bg-[#0066ff]" /> Fresh
              </span>
              <span className="flex items-center gap-1.5">
                <span className="w-2.5 h-2.5 rounded-full bg-rose-500" /> Spoiled
              </span>
            </div>
          </div>

          {/* Bar Chart Visualizer */}
          <div className="pt-6 pb-2 grid grid-cols-7 gap-3 sm:gap-6 items-end h-64 border-b border-slate-100">
            {weeklyTraffic.map((item, idx) => {
              const heightPercent = Math.round((item.count / 2000) * 100);
              const freshRatio = Math.round((item.fresh / item.count) * 100);
              return (
                <div key={idx} className="flex flex-col items-center gap-2 h-full justify-end group">
                  <div className="text-[11px] font-mono font-bold text-slate-400 opacity-0 group-hover:opacity-100 transition-opacity">
                    {item.count}
                  </div>
                  <div
                    className="w-full max-w-[42px] bg-slate-100 rounded-2xl overflow-hidden flex flex-col justify-end transition-all group-hover:scale-105"
                    style={{ height: `${heightPercent}%` }}
                  >
                    <div
                      className="w-full bg-[#0066ff] transition-all"
                      style={{ height: `${freshRatio}%` }}
                    />
                    <div
                      className="w-full bg-rose-500 transition-all"
                      style={{ height: `${100 - freshRatio}%` }}
                    />
                  </div>
                  <span className="text-xs font-heading font-bold uppercase tracking-wider text-slate-600">
                    {item.day}
                  </span>
                </div>
              );
            })}
          </div>

          <div className="mt-4 flex items-center justify-between text-xs text-slate-400">
            <span className="flex items-center gap-1">
              <Calendar size={13} /> Current 7-day period
            </span>
            <span className="font-bold text-slate-700">Total: 9,549 scans</span>
          </div>
        </div>

        {/* Grade Breakdown Summary */}
        <div className="lg:col-span-4 bg-white rounded-3xl border border-slate-200 p-6 sm:p-7 shadow-xs flex flex-col justify-between">
          <div>
            <h2 className="font-heading font-black text-lg text-slate-950 uppercase tracking-tight mb-1">
              Freshness Distribution
            </h2>
            <p className="font-sans text-xs text-slate-500 mb-6">Aggregated quality classifications</p>

            <div className="space-y-4">
              <div className="p-4 rounded-2xl bg-emerald-50/70 border border-emerald-100 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <CheckCircle2 size={20} className="text-emerald-600" />
                  <div>
                    <p className="font-heading font-black text-xs uppercase tracking-wider text-emerald-900">Fresh (Grade A)</p>
                    <p className="text-[11px] text-emerald-700">1,060 scans</p>
                  </div>
                </div>
                <span className="font-heading font-black text-lg text-emerald-900">74.2%</span>
              </div>

              <div className="p-4 rounded-2xl bg-amber-50/70 border border-amber-100 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <AlertTriangle size={20} className="text-amber-600" />
                  <div>
                    <p className="font-heading font-black text-xs uppercase tracking-wider text-amber-900">Moderate (Grade B)</p>
                    <p className="text-[11px] text-amber-700">227 scans</p>
                  </div>
                </div>
                <span className="font-heading font-black text-lg text-amber-900">15.9%</span>
              </div>

              <div className="p-4 rounded-2xl bg-rose-50/70 border border-rose-100 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <XCircle size={20} className="text-rose-600" />
                  <div>
                    <p className="font-heading font-black text-xs uppercase tracking-wider text-rose-900">Spoiled (Grade C)</p>
                    <p className="text-[11px] text-rose-700">142 scans</p>
                  </div>
                </div>
                <span className="font-heading font-black text-lg text-rose-900">9.9%</span>
              </div>
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-slate-100 text-xs text-slate-500 flex items-center gap-2">
            <Sparkles size={14} className="text-[#0066ff]" />
            <span>Freshness rate is +3.4% higher than last week</span>
          </div>
        </div>

      </div>

      {/* Sensory AI Model Precision */}
      <div className="bg-white rounded-3xl border border-slate-200 p-6 sm:p-8 shadow-xs">
        <div className="mb-6">
          <h2 className="font-heading font-black text-lg text-slate-950 uppercase tracking-tight">
            Sensory Feature Precision
          </h2>
          <p className="font-sans text-xs text-slate-500">Benchmark accuracy of computer vision sub-classifiers</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {sensoryMetrics.map((metric, i) => (
            <div key={i} className="p-5 rounded-2xl bg-slate-50 border border-slate-200/80 flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between mb-3">
                  <div className="p-2 rounded-xl bg-white border border-slate-200 text-[#0066ff]">
                    <Eye size={18} />
                  </div>
                  <span className="font-heading font-black text-lg text-slate-950">
                    {metric.accuracy}
                  </span>
                </div>
                <h3 className="font-heading font-black text-xs uppercase tracking-tight text-slate-900 mb-1">
                  {metric.name}
                </h3>
                <p className="font-sans text-xs text-slate-500 leading-relaxed">
                  {metric.description}
                </p>
              </div>

              <div className="mt-4 pt-3 border-t border-slate-200/60 w-full">
                <div className="w-full h-1.5 rounded-full bg-slate-200 overflow-hidden">
                  <div className="h-full bg-[#0066ff] rounded-full" style={{ width: `${metric.score}%` }} />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Species Distribution Table */}
      <div className="bg-white rounded-3xl border border-slate-200 p-6 sm:p-8 shadow-xs">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="font-heading font-black text-lg text-slate-950 uppercase tracking-tight">
              Species Breakdown
            </h2>
            <p className="font-sans text-xs text-slate-500">Scanned species breakdown and associated quality ratings</p>
          </div>
          <div className="inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-wider text-slate-500">
            <Layers size={14} className="text-[#0066ff]" />
            <span>5 Core Species</span>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-slate-100 text-[11px] font-heading font-bold uppercase tracking-wider text-slate-400">
                <th className="pb-3 pl-2">Fish Species</th>
                <th className="pb-3">Total Scans</th>
                <th className="pb-3">Fresh %</th>
                <th className="pb-3">Moderate %</th>
                <th className="pb-3">Spoiled %</th>
                <th className="pb-3 text-right pr-2">Quality Index</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-sans text-xs">
              {speciesStats.map((item, idx) => (
                <tr key={idx} className="hover:bg-slate-50/70 transition-colors">
                  <td className="py-4 pl-2 font-heading font-bold text-slate-900">{item.name}</td>
                  <td className="py-4 font-mono font-bold text-slate-700">{item.total}</td>
                  <td className="py-4">
                    <span className="font-semibold text-emerald-600">{item.freshPercent}%</span>
                  </td>
                  <td className="py-4">
                    <span className="font-semibold text-amber-600">{item.moderatePercent}%</span>
                  </td>
                  <td className="py-4">
                    <span className="font-semibold text-rose-600">{item.spoiledPercent}%</span>
                  </td>
                  <td className="py-4 text-right pr-2">
                    <span className="inline-flex items-center gap-1 font-heading font-black text-xs text-slate-900 bg-slate-100 px-2.5 py-1 rounded-lg">
                      ⭐ {item.score} / 10
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

    </div>
  );
};

export default Analytics;
