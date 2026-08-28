import React, { useState } from 'react';
import {
  Search,
  CheckCircle2,
  AlertTriangle,
  XCircle,
  Eye,
  ChevronLeft,
  ChevronRight,
  X,
  Sparkles,
  Zap,
} from 'lucide-react';

interface ScanItem {
  id: string;
  species: string;
  grade: 'Fresh' | 'Moderate' | 'Spoiled';
  confidence: number;
  eyeClarity: string;
  gillStatus: string;
  fleshTexture: string;
  user: string;
  userType: 'Inspector' | 'Vendor' | 'Guest';
  date: string;
  inferenceTime: string;
}

export const Classifications: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedGrade, setSelectedGrade] = useState<'all' | 'Fresh' | 'Moderate' | 'Spoiled'>('all');
  const [selectedScan, setSelectedScan] = useState<ScanItem | null>(null);

  const mockScans: ScanItem[] = [
    {
      id: 'SCN-9912',
      species: 'Bangus (Milkfish)',
      grade: 'Fresh',
      confidence: 97.8,
      eyeClarity: 'Clear, convex, transparent cornea',
      gillStatus: 'Vivid crimson red, fresh mucus',
      fleshTexture: 'Firm, elastic, tight scales',
      user: 'Juan Santos',
      userType: 'Inspector',
      date: 'Aug 28, 2026 12:20 PM',
      inferenceTime: '192ms',
    },
    {
      id: 'SCN-9911',
      species: 'Galunggong (Round Scad)',
      grade: 'Fresh',
      confidence: 95.2,
      eyeClarity: 'Translucent pupil with high reflectivity',
      gillStatus: 'Bright pinkish-red',
      fleshTexture: 'Resilient and stiff body texture',
      user: 'Guest #4829',
      userType: 'Guest',
      date: 'Aug 28, 2026 12:14 PM',
      inferenceTime: '210ms',
    },
    {
      id: 'SCN-9910',
      species: 'Tilapia',
      grade: 'Moderate',
      confidence: 83.4,
      eyeClarity: 'Slight cloudy haze over lens',
      gillStatus: 'Pale pink with fading pigmentation',
      fleshTexture: 'Moderate softness upon depression',
      user: 'Maria D. (Pasay Fish Port)',
      userType: 'Vendor',
      date: 'Aug 28, 2026 12:01 PM',
      inferenceTime: '228ms',
    },
    {
      id: 'SCN-9909',
      species: 'Tambakol (Yellowfin Tuna)',
      grade: 'Spoiled',
      confidence: 91.1,
      eyeClarity: 'Opaque sunken cornea with milky veil',
      gillStatus: 'Brownish-gray discoloration',
      fleshTexture: 'Soft, flaccid, loose scaling',
      user: 'Carlos Mendoza',
      userType: 'Inspector',
      date: 'Aug 28, 2026 11:45 AM',
      inferenceTime: '198ms',
    },
    {
      id: 'SCN-9908',
      species: 'Maya-Maya (Red Snapper)',
      grade: 'Fresh',
      confidence: 98.4,
      eyeClarity: 'Bright crystal cornea, zero haze',
      gillStatus: 'Intense blood-red gills',
      fleshTexture: 'Pristine firmness',
      user: 'Elena Ramos',
      userType: 'Inspector',
      date: 'Aug 28, 2026 11:32 AM',
      inferenceTime: '185ms',
    },
    {
      id: 'SCN-9907',
      species: 'Bangus (Milkfish)',
      grade: 'Moderate',
      confidence: 79.6,
      eyeClarity: 'Minor opacity on outer ring',
      gillStatus: 'Dull reddish-brown',
      fleshTexture: 'Slightly yielding scales',
      user: 'Guest #4828',
      userType: 'Guest',
      date: 'Aug 28, 2026 11:15 AM',
      inferenceTime: '219ms',
    },
    {
      id: 'SCN-9906',
      species: 'Galunggong (Round Scad)',
      grade: 'Spoiled',
      confidence: 88.7,
      eyeClarity: 'Completely opaque pupil, collapsed lens',
      gillStatus: 'Discolored gray with sour mucus',
      fleshTexture: 'Soft, indentation remains',
      user: 'Navotas QC Station #2',
      userType: 'Inspector',
      date: 'Aug 28, 2026 10:58 AM',
      inferenceTime: '202ms',
    },
  ];

  const filteredScans = mockScans.filter((scan) => {
    const matchesSearch =
      scan.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      scan.species.toLowerCase().includes(searchTerm.toLowerCase()) ||
      scan.user.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesGrade = selectedGrade === 'all' || scan.grade === selectedGrade;

    return matchesSearch && matchesGrade;
  });

  const getGradeBadge = (grade: ScanItem['grade']) => {
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
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white rounded-3xl border border-slate-200 p-6 sm:p-8 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-2">
            <Eye size={13} />
            <span>Audit & Verification</span>
          </div>
          <h1 className="font-heading font-black text-2xl sm:text-3xl text-slate-950 uppercase tracking-tight">
            Classifications Database
          </h1>
          <p className="font-sans text-xs sm:text-sm text-slate-500 mt-1">
            Complete registry of automated computer vision classifications and sensory logs.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <span className="inline-flex items-center gap-2 px-3.5 py-2 rounded-2xl bg-slate-100 font-mono text-xs font-bold text-slate-700">
            <span className="w-2 h-2 rounded-full bg-[#0066ff]" />
            {mockScans.length} Registered Records
          </span>
        </div>
      </div>

      {/* Filter & Search Bar */}
      <div className="bg-white rounded-3xl border border-slate-200 p-5 shadow-xs flex flex-col sm:flex-row items-center justify-between gap-4">
        {/* Search */}
        <div className="relative w-full sm:w-80">
          <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
            <Search size={16} />
          </div>
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search by ID, species, or inspector..."
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl font-sans text-xs sm:text-sm placeholder-slate-400 focus:bg-white focus:outline-none focus:border-[#0066ff] transition-all"
          />
        </div>

        {/* Grade Filter Pills */}
        <div className="flex items-center gap-2 w-full sm:w-auto overflow-x-auto pb-1 sm:pb-0">
          {(['all', 'Fresh', 'Moderate', 'Spoiled'] as const).map((grade) => (
            <button
              key={grade}
              onClick={() => setSelectedGrade(grade)}
              className={`px-3.5 py-1.5 rounded-xl text-xs font-bold uppercase tracking-wider transition-all cursor-pointer whitespace-nowrap ${
                selectedGrade === grade
                  ? 'bg-slate-950 text-white shadow-xs'
                  : 'bg-slate-100 hover:bg-slate-200 text-slate-600'
              }`}
            >
              {grade === 'all' ? 'All Grades' : grade}
            </button>
          ))}
        </div>
      </div>

      {/* Classifications Table */}
      <div className="bg-white rounded-3xl border border-slate-200 overflow-hidden shadow-xs">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-slate-100 bg-slate-50/60 text-[11px] font-heading font-bold uppercase tracking-wider text-slate-400">
                <th className="py-3.5 pl-6">Scan ID</th>
                <th className="py-3.5">Fish Species</th>
                <th className="py-3.5">Freshness Grade</th>
                <th className="py-3.5">AI Confidence</th>
                <th className="py-3.5">Inspected By</th>
                <th className="py-3.5">Timestamp</th>
                <th className="py-3.5 text-right pr-6">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-sans text-xs">
              {filteredScans.map((scan) => (
                <tr key={scan.id} className="hover:bg-slate-50/80 transition-colors group">
                  <td className="py-4 pl-6 font-mono font-bold text-slate-900">{scan.id}</td>
                  <td className="py-4 font-heading font-bold text-slate-800">{scan.species}</td>
                  <td className="py-4">{getGradeBadge(scan.grade)}</td>
                  <td className="py-4">
                    <span className="font-mono font-bold text-slate-700">{scan.confidence}%</span>
                  </td>
                  <td className="py-4">
                    <div>
                      <span className="font-semibold text-slate-800 block">{scan.user}</span>
                      <span className="text-[10px] text-slate-400 font-bold uppercase tracking-wider">
                        {scan.userType}
                      </span>
                    </div>
                  </td>
                  <td className="py-4 text-slate-400">{scan.date}</td>
                  <td className="py-4 text-right pr-6">
                    <button
                      onClick={() => setSelectedScan(scan)}
                      className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl bg-blue-50 hover:bg-[#0066ff] text-[#0066ff] hover:text-white font-heading text-xs font-bold uppercase tracking-wider transition-colors cursor-pointer"
                    >
                      <Eye size={13} />
                      <span>Inspect</span>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Table Footer / Pagination */}
        <div className="p-4 sm:p-5 bg-white border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
          <span>Showing {filteredScans.length} of {mockScans.length} scans</span>
          <div className="flex items-center gap-2">
            <button className="p-2 rounded-lg border border-slate-200 text-slate-400 hover:text-slate-700 disabled:opacity-50 cursor-pointer">
              <ChevronLeft size={16} />
            </button>
            <span className="font-bold text-slate-800 px-2">Page 1 of 1</span>
            <button className="p-2 rounded-lg border border-slate-200 text-slate-400 hover:text-slate-700 disabled:opacity-50 cursor-pointer">
              <ChevronRight size={16} />
            </button>
          </div>
        </div>
      </div>

      {/* Inspection Modal / Drawer */}
      {selectedScan && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-lg w-full border border-slate-200 shadow-2xl p-6 sm:p-8 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between mb-6 pb-4 border-b border-slate-100">
              <div>
                <span className="font-mono text-xs text-slate-400 block">{selectedScan.id}</span>
                <h3 className="font-heading font-black text-xl text-slate-950 uppercase tracking-tight">
                  {selectedScan.species}
                </h3>
              </div>
              <button
                onClick={() => setSelectedScan(null)}
                className="p-2 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-700 cursor-pointer"
              >
                <X size={20} />
              </button>
            </div>

            <div className="space-y-4">
              <div className="flex items-center justify-between p-4 rounded-2xl bg-slate-50 border border-slate-200/80">
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Assessed Freshness</p>
                  <p className="font-heading font-black text-base text-slate-900">{selectedScan.grade}</p>
                </div>
                <div>{getGradeBadge(selectedScan.grade)}</div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="p-3.5 rounded-2xl bg-slate-50 border border-slate-200/80">
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Confidence</p>
                  <p className="font-heading font-bold text-sm text-[#0066ff]">{selectedScan.confidence}%</p>
                </div>
                <div className="p-3.5 rounded-2xl bg-slate-50 border border-slate-200/80">
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Inference Latency</p>
                  <p className="font-heading font-bold text-sm text-slate-800">{selectedScan.inferenceTime}</p>
                </div>
              </div>

              <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-2.5 text-xs">
                <p className="font-heading font-bold uppercase tracking-wider text-slate-700 flex items-center gap-1.5">
                  <Sparkles size={13} className="text-[#0066ff]" /> Sensory Cue Breakdown
                </p>
                <div>
                  <span className="font-semibold text-slate-700">Eye Cornea: </span>
                  <span className="text-slate-500">{selectedScan.eyeClarity}</span>
                </div>
                <div>
                  <span className="font-semibold text-slate-700">Gill Pigmentation: </span>
                  <span className="text-slate-500">{selectedScan.gillStatus}</span>
                </div>
                <div>
                  <span className="font-semibold text-slate-700">Flesh Elasticity: </span>
                  <span className="text-slate-500">{selectedScan.fleshTexture}</span>
                </div>
              </div>

              <div className="text-xs text-slate-400 pt-2 flex items-center justify-between">
                <span>Submitted by: <strong className="text-slate-700">{selectedScan.user}</strong></span>
                <span>{selectedScan.date}</span>
              </div>
            </div>

            <div className="mt-6 pt-4 border-t border-slate-100 flex items-center justify-end gap-3">
              <button
                onClick={() => setSelectedScan(null)}
                className="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-heading text-xs font-bold uppercase tracking-wider transition-colors cursor-pointer"
              >
                Close
              </button>
              <button
                onClick={() => {
                  alert(`Verified scan record: ${selectedScan.id}`);
                  setSelectedScan(null);
                }}
                className="px-4 py-2 rounded-xl bg-[#0066ff] hover:bg-blue-600 text-white font-heading text-xs font-bold uppercase tracking-wider transition-colors cursor-pointer flex items-center gap-1.5 shadow-xs"
              >
                <Zap size={14} />
                <span>Verify Record</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Classifications;
