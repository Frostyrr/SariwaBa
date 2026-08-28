import React from 'react';
import {
  TrendingUp,
  Zap,
  CheckCircle2,
  AlertTriangle,
  XCircle,
  Users,
  Activity,
  ArrowUpRight,
  ShieldCheck,
  Clock,
  Sparkles,
  Layers,
  ChevronRight,
} from 'lucide-react';

interface OverviewProps {
  onNavigateTab?: (tab: 'overview' | 'analytics' | 'classifications' | 'users') => void;
}

export const Overview: React.FC<OverviewProps> = ({ onNavigateTab }) => {
  const statCards = [
    {
      title: 'Total Scans Today',
      value: '1,429',
      change: '+14.8%',
      trend: 'up',
      icon: <Zap size={20} className="text-[#0066ff]" />,
      bg: 'bg-blue-50/70',
      border: 'border-blue-100',
    },
    {
      title: 'Avg. AI Confidence',
      value: '95.4%',
      change: '+1.2%',
      trend: 'up',
      icon: <ShieldCheck size={20} className="text-emerald-600" />,
      bg: 'bg-emerald-50/70',
      border: 'border-emerald-100',
    },
    {
      title: 'Fresh Ratio',
      value: '74.2%',
      change: '1,060 Fresh',
      trend: 'neutral',
      icon: <CheckCircle2 size={20} className="text-blue-600" />,
      bg: 'bg-indigo-50/70',
      border: 'border-indigo-100',
    },
    {
      title: 'Active Inspectors',
      value: '348',
      change: '+22 new today',
      trend: 'up',
      icon: <Users size={20} className="text-violet-600" />,
      bg: 'bg-violet-50/70',
      border: 'border-violet-100',
    },
  ];

  const recentScans = [
    {
      id: 'SCN-8841',
      species: 'Bangus (Milkfish)',
      grade: 'Fresh',
      confidence: 97.4,
      latency: '198ms',
      time: '2 mins ago',
      inspector: 'Market Vendor #12',
    },
    {
      id: 'SCN-8840',
      species: 'Galunggong (Round Scad)',
      grade: 'Fresh',
      confidence: 94.1,
      latency: '215ms',
      time: '7 mins ago',
      inspector: 'Guest User',
    },
    {
      id: 'SCN-8839',
      species: 'Tilapia',
      grade: 'Moderate',
      confidence: 82.5,
      latency: '230ms',
      time: '14 mins ago',
      inspector: 'Quality Lead (QC-3)',
    },
    {
      id: 'SCN-8838',
      species: 'Tambakol (Yellowfin Tuna)',
      grade: 'Spoiled',
      confidence: 91.8,
      latency: '204ms',
      time: '22 mins ago',
      inspector: 'Navotas Port Inspector',
    },
    {
      id: 'SCN-8837',
      species: 'Maya-Maya (Red Snapper)',
      grade: 'Fresh',
      confidence: 98.2,
      latency: '189ms',
      time: '31 mins ago',
      inspector: 'Fishery Officer #4',
    },
  ];

  const getGradePill = (grade: string) => {
    switch (grade) {
      case 'Fresh':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold uppercase tracking-wider bg-emerald-50 text-emerald-700 border border-emerald-200">
            <CheckCircle2 size={12} className="text-emerald-600" />
            Fresh
          </span>
        );
      case 'Moderate':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold uppercase tracking-wider bg-amber-50 text-amber-700 border border-amber-200">
            <AlertTriangle size={12} className="text-amber-600" />
            Moderate
          </span>
        );
      case 'Spoiled':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold uppercase tracking-wider bg-rose-50 text-rose-700 border border-rose-200">
            <XCircle size={12} className="text-rose-600" />
            Spoiled
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div className="space-y-8 animate-blur-in">
      {/* Top Banner / Welcome with Blur Resolution */}
      <div className="bg-white/95 backdrop-blur-md rounded-3xl border border-slate-200 p-6 sm:p-8 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-6 animate-blur-in-up">
        <div>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50/90 backdrop-blur-xs border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-2">
            <Sparkles size={13} />
            <span>AI Operations Center</span>
          </div>
          <h1 className="font-heading font-black text-2xl sm:text-3xl text-slate-950 uppercase tracking-tight">
            System Overview
          </h1>
          <p className="font-sans text-xs sm:text-sm text-slate-500 mt-1">
            Real-time telemetry and classification metrics across all connected scanning stations.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="bg-slate-50 border border-slate-200 rounded-2xl px-4 py-3 flex items-center gap-3">
            <div className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse" />
            <div>
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Model Engine</p>
              <p className="font-heading text-xs font-bold text-slate-800">FreshVision v1.4 • 99.9% Uptime</p>
            </div>
          </div>
        </div>
      </div>

      {/* KPI Cards Grid with Staggered Delays */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {statCards.map((stat, i) => {
          const delays = ['delay-100', 'delay-200', 'delay-300', 'delay-400'];
          return (
            <div
              key={i}
              className={`bg-white/95 backdrop-blur-md rounded-3xl border border-slate-200 p-6 shadow-xs flex flex-col justify-between transition-all hover:shadow-xl hover:shadow-blue-600/5 hover:border-slate-300 hover:-translate-y-1 group animate-blur-in-up ${delays[i]}`}
            >
              <div className="flex items-center justify-between mb-4">
                <span className="font-heading text-xs font-bold uppercase tracking-wider text-slate-500">
                  {stat.title}
                </span>
                <div className={`p-2.5 rounded-xl ${stat.bg} ${stat.border} border shadow-xs transition-transform group-hover:scale-105`}>
                  {stat.icon}
                </div>
              </div>
              <div>
                <div className="font-heading font-black text-3xl text-slate-950 tracking-tight">
                  {stat.value}
                </div>
                <div className="flex items-center gap-1.5 mt-2 text-xs font-semibold text-emerald-600">
                  <TrendingUp size={13} />
                  <span>{stat.change}</span>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* 2-Column: Live Feed & Model Health with Staggered Delays */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        
        {/* Left 8 Cols: Recent Inferences Live Feed */}
        <div className="lg:col-span-8 bg-white/95 backdrop-blur-md rounded-3xl border border-slate-200 p-6 sm:p-7 shadow-xs animate-blur-in-up delay-250">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="font-heading font-black text-lg text-slate-950 uppercase tracking-tight">
                Recent Inferences
              </h2>
              <p className="font-sans text-xs text-slate-500">Live classifications processed by the AI server</p>
            </div>
            <button
              onClick={() => onNavigateTab && onNavigateTab('classifications')}
              className="inline-flex items-center gap-1 text-xs font-bold uppercase tracking-wider text-[#0066ff] hover:underline cursor-pointer"
            >
              <span>View All</span>
              <ArrowUpRight size={14} />
            </button>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-slate-100 text-[11px] font-heading font-bold uppercase tracking-wider text-slate-400">
                  <th className="pb-3 pl-2">Scan ID</th>
                  <th className="pb-3">Species</th>
                  <th className="pb-3">Freshness Grade</th>
                  <th className="pb-3">Confidence</th>
                  <th className="pb-3">Latency</th>
                  <th className="pb-3 text-right pr-2">Time</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-sans text-xs">
                {recentScans.map((scan) => (
                  <tr key={scan.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="py-3.5 pl-2 font-mono font-bold text-slate-900">{scan.id}</td>
                    <td className="py-3.5 font-heading font-bold text-slate-800">{scan.species}</td>
                    <td className="py-3.5">{getGradePill(scan.grade)}</td>
                    <td className="py-3.5 font-heading font-bold text-slate-700">{scan.confidence}%</td>
                    <td className="py-3.5 text-slate-500 font-mono">{scan.latency}</td>
                    <td className="py-3.5 text-right pr-2 text-slate-400">{scan.time}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Right 4 Cols: Model Health & Quick Stats */}
        <div className="lg:col-span-4 space-y-6 animate-blur-in-up delay-350">
          
          {/* Hardware & Latency Telemetry */}
          <div className="bg-white/95 backdrop-blur-md rounded-3xl border border-slate-200 p-6 shadow-xs">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-heading font-black text-sm uppercase tracking-tight text-slate-900">
                Inference Telemetry
              </h3>
              <Activity size={16} className="text-[#0066ff]" />
            </div>

            <div className="space-y-4">
              <div>
                <div className="flex items-center justify-between text-xs font-semibold text-slate-600 mb-1">
                  <span>GPU Compute Utilization</span>
                  <span className="font-mono text-slate-900">38%</span>
                </div>
                <div className="w-full h-2 rounded-full bg-slate-100 overflow-hidden">
                  <div className="h-full bg-[#0066ff] rounded-full transition-all duration-500" style={{ width: '38%' }} />
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between text-xs font-semibold text-slate-600 mb-1">
                  <span>Average Inference Latency</span>
                  <span className="font-mono text-emerald-600">208 ms</span>
                </div>
                <div className="w-full h-2 rounded-full bg-slate-100 overflow-hidden">
                  <div className="h-full bg-emerald-500 rounded-full transition-all duration-500" style={{ width: '22%' }} />
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between text-xs font-semibold text-slate-600 mb-1">
                  <span>Detection Accuracy Target</span>
                  <span className="font-mono text-blue-600">96.8%</span>
                </div>
                <div className="w-full h-2 rounded-full bg-slate-100 overflow-hidden">
                  <div className="h-full bg-blue-600 rounded-full transition-all duration-500" style={{ width: '96.8%' }} />
                </div>
              </div>
            </div>

            <div className="mt-5 pt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
              <span className="flex items-center gap-1.5">
                <Clock size={13} className="text-[#0066ff]" /> Last model checkpoint
              </span>
              <span className="font-mono font-bold text-slate-700">1 hour ago</span>
            </div>
          </div>

          {/* Quick Action Navigation */}
          <div className="bg-slate-950 text-white rounded-3xl p-6 shadow-xl shadow-slate-900/10 flex flex-col justify-between">
            <div>
              <div className="w-9 h-9 rounded-xl bg-white/10 flex items-center justify-center text-[#0066ff] mb-4">
                <Layers size={18} />
              </div>
              <h3 className="font-heading font-black text-base uppercase tracking-tight mb-1">
                Deep Analytics
              </h3>
              <p className="font-sans text-xs text-slate-400 leading-relaxed mb-4">
                Explore sensory cue breakdowns, species distributions, and weekly quality curves.
              </p>
            </div>

            <button
              onClick={() => onNavigateTab && onNavigateTab('analytics')}
              className="w-full py-2.5 px-4 bg-[#0066ff] hover:bg-blue-500 text-white rounded-xl font-heading text-xs font-bold uppercase tracking-wider transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
            >
              <span>Open Analytics</span>
              <ChevronRight size={14} />
            </button>
          </div>

        </div>

      </div>
    </div>
  );
};

export default Overview;
