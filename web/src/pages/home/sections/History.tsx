import React, { useState } from 'react';
import { History as HistoryIcon, Clock, Filter, Eye, CheckCircle2, AlertTriangle, XCircle, RotateCcw } from 'lucide-react';

interface ScanLogItem {
  id: string;
  species: string;
  timestamp: string;
  grade: 'Fresh' | 'Moderate' | 'Spoiled';
  confidence: number;
  indicators: string;
}

export const History: React.FC = () => {
  const [filter, setFilter] = useState<'all' | 'Fresh' | 'Moderate' | 'Spoiled'>('all');

  // Sample placeholder log data
  const sampleLogs: ScanLogItem[] = [
    {
      id: 'SCAN-004',
      species: 'Bangus (Milkfish)',
      timestamp: 'Just now',
      grade: 'Fresh',
      confidence: 96,
      indicators: 'Bright clear pupils, vivid red gills',
    },
    {
      id: 'SCAN-003',
      species: 'Galunggong (Round Scad)',
      timestamp: '15 mins ago',
      grade: 'Fresh',
      confidence: 92,
      indicators: 'Intact scales, translucent eye cornea',
    },
    {
      id: 'SCAN-002',
      species: 'Tilapia',
      timestamp: '2 hours ago',
      grade: 'Moderate',
      confidence: 78,
      indicators: 'Slight eye cloudiness, pale gill arches',
    },
    {
      id: 'SCAN-001',
      species: 'Tambakol (Yellowfin Tuna slice)',
      timestamp: 'Yesterday',
      grade: 'Spoiled',
      confidence: 89,
      indicators: 'Sunken opaque eyes, discolored brownish gills',
    },
  ];

  const filteredLogs = filter === 'all' ? sampleLogs : sampleLogs.filter((log) => log.grade === filter);

  const getGradeBadge = (grade: ScanLogItem['grade']) => {
    switch (grade) {
      case 'Fresh':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-emerald-50 text-emerald-700 border border-emerald-200">
            <CheckCircle2 size={13} className="text-emerald-600" />
            Fresh
          </span>
        );
      case 'Moderate':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-amber-50 text-amber-700 border border-amber-200">
            <AlertTriangle size={13} className="text-amber-600" />
            Moderate
          </span>
        );
      case 'Spoiled':
        return (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-rose-50 text-rose-700 border border-rose-200">
            <XCircle size={13} className="text-rose-600" />
            Spoiled
          </span>
        );
    }
  };

  return (
    <section id="history" className="py-20 md:py-28 bg-white relative border-b border-slate-200/80">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between mb-12 gap-6">
          <div>
            <div className="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full bg-blue-50 border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-4">
              <HistoryIcon size={14} />
              <span>Session History</span>
            </div>
            <h2 className="font-heading font-black text-3xl sm:text-4xl lg:text-5xl text-slate-950 uppercase tracking-tight">
              Classification Logs
            </h2>
            <p className="font-sans text-base text-slate-600 mt-2 max-w-xl">
              Chronological records of recent camera captures and AI freshness evaluations.
            </p>
          </div>

          {/* Filter Pills */}
          <div className="flex items-center gap-2 flex-wrap">
            <span className="text-xs font-bold uppercase tracking-wider text-slate-400 flex items-center gap-1 mr-1">
              <Filter size={13} /> Filter:
            </span>
            {(['all', 'Fresh', 'Moderate', 'Spoiled'] as const).map((grade) => (
              <button
                key={grade}
                onClick={() => setFilter(grade)}
                className={`px-3.5 py-1.5 rounded-full text-xs font-bold uppercase tracking-wider transition-all cursor-pointer ${
                  filter === grade
                    ? 'bg-slate-900 text-white shadow-xs'
                    : 'bg-slate-100 hover:bg-slate-200 text-slate-600'
                }`}
              >
                {grade === 'all' ? 'All Tries' : grade}
              </button>
            ))}
          </div>
        </div>

        {/* Logs Table / Cards */}
        <div className="bg-[#fbfbfb] rounded-3xl border border-slate-200 overflow-hidden shadow-xs">
          
          <div className="divide-y divide-slate-200">
            {filteredLogs.map((log) => (
              <div
                key={log.id}
                className="p-5 sm:p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 hover:bg-white transition-colors"
              >
                {/* Left Info */}
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-white border border-slate-200 shadow-xs flex items-center justify-center text-[#0066ff] shrink-0 mt-0.5 sm:mt-0">
                    <Eye size={22} />
                  </div>
                  <div>
                    <div className="flex items-center gap-2 flex-wrap mb-1">
                      <span className="font-heading font-black text-sm sm:text-base text-slate-900 uppercase tracking-tight">
                        {log.species}
                      </span>
                      <span className="text-[11px] font-semibold text-slate-400 font-mono">
                        {log.id}
                      </span>
                    </div>
                    <p className="font-sans text-xs sm:text-sm text-slate-500">
                      {log.indicators}
                    </p>
                  </div>
                </div>

                {/* Right Badges & Confidence */}
                <div className="flex items-center gap-4 sm:gap-6 self-end sm:self-center">
                  <div className="flex items-center gap-1.5 text-xs text-slate-400">
                    <Clock size={13} />
                    <span>{log.timestamp}</span>
                  </div>

                  <div className="text-right">
                    <span className="font-heading font-bold text-xs text-slate-700 block">
                      {log.confidence}% AI Confidence
                    </span>
                  </div>

                  <div>{getGradeBadge(log.grade)}</div>
                </div>
              </div>
            ))}
          </div>

          {/* Footer Bar */}
          <div className="p-4 sm:p-5 bg-white border-t border-slate-200 flex items-center justify-between text-xs text-slate-500">
            <span>Showing {filteredLogs.length} recent scan sessions (UI Placeholder)</span>
            <button
              onClick={() => setFilter('all')}
              className="inline-flex items-center gap-1.5 font-bold uppercase tracking-wider text-[#0066ff] hover:underline cursor-pointer"
            >
              <RotateCcw size={12} />
              Reset Logs
            </button>
          </div>

        </div>

      </div>
    </section>
  );
};

export default History;
