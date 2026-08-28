import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Button } from '../../../components/ui/Button';
import {
  Camera,
  Upload,
  Scan,
  ArrowRight,
  Check,
  CheckCircle2,
  RotateCcw,
  Sparkles,
  Loader2,
  Eye,
  Activity
} from 'lucide-react';

export const Hero: React.FC = () => {
  const [activePlaceholderTab, setActivePlaceholderTab] = useState<'camera' | 'upload'>('camera');
  const [scanState, setScanState] = useState<'idle' | 'scanning' | 'complete'>('idle');
  const [scanStepText, setScanStepText] = useState('Initializing AI model...');

  const handleStartLiveScan = () => {
    setActivePlaceholderTab('camera');
    setScanState('scanning');
    setScanStepText('Focusing camera stream on target...');

    setTimeout(() => {
      setScanStepText('Analyzing corneal opacity & gill pigmentation...');
    }, 600);

    setTimeout(() => {
      setScanStepText('Computing freshness classification confidence...');
    }, 1100);

    setTimeout(() => {
      setScanState('complete');
    }, 1600);
  };

  const handleResetScan = () => {
    setScanState('idle');
  };

  return (
    <section id="hero" className="relative min-h-[calc(100vh-73px)] flex flex-col justify-center pt-8 pb-16 md:pt-12 md:pb-20 overflow-hidden scroll-mt-20">
      
      {/* Ambient Blur Optical Glow Elements */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[540px] h-[340px] bg-blue-500/10 rounded-full blur-3xl pointer-events-none -z-10 animate-ambient-glow" />
      <div className="absolute top-1/3 right-10 w-72 h-72 bg-[#0066ff]/8 rounded-full blur-3xl pointer-events-none -z-10 animate-ambient-glow delay-300" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* 2-Column Grid: Text on Left, Viewfinder on Right */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-10 items-center">
          
          {/* Left Column: Headline, Description & CTAs with Staggered Blur-In Animations */}
          <div className="lg:col-span-6 flex flex-col items-center lg:items-start text-center lg:text-left">
            
            {/* Main Headline */}
            <h1 className="font-heading font-black text-4xl sm:text-6xl md:text-7xl xl:text-8xl tracking-tight text-slate-950 uppercase leading-[1.02] mb-6 animate-blur-in-up delay-100">
              Sariwa <span className="text-[#0066ff]">Ba?</span>
            </h1>

            {/* Short Description */}
            <p className="font-sans font-normal text-lg sm:text-xl text-slate-600 max-w-xl leading-relaxed mb-8 animate-blur-in-up delay-200">
              Scan a fish and check its freshness in seconds
            </p>

            {/* CTA Buttons with Active Scanning Trigger */}
            <div className="flex flex-col sm:flex-row items-center gap-4 sm:gap-6 w-full sm:w-auto mb-6 animate-blur-in-up delay-300">
              <Button
                variant="primary"
                size="lg"
                className={`w-full sm:w-auto transition-all duration-300 ${
                  scanState === 'scanning'
                    ? 'ring-4 ring-blue-500/40 shadow-blue-500/50 bg-[#0052cc]'
                    : 'shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40'
                }`}
                icon={
                  scanState === 'scanning' ? (
                    <Loader2 size={18} className="animate-spin" />
                  ) : (
                    <Camera size={18} />
                  )
                }
                onClick={handleStartLiveScan}
                disabled={scanState === 'scanning'}
              >
                {scanState === 'scanning' ? 'Running AI Scan...' : 'Try Live Scanner'}
              </Button>

              <Link
                to="/register"
                className="inline-flex items-center gap-2 text-sm font-bold uppercase tracking-wider text-slate-800 hover:text-[#0066ff] py-2 px-4 transition-colors cursor-pointer group"
              >
                <span>Get Started</span>
                <ArrowRight size={16} className="text-[#0066ff] transition-transform group-hover:translate-x-1" />
              </Link>
            </div>

            {/* Helper Micro-copy */}
            <p className="text-xs font-medium text-slate-400 flex items-center gap-1.5 animate-blur-in-up delay-400">
              <Check size={14} className="text-[#0066ff]" />
              <span>Try the classification without an account &mdash; instant demo</span>
            </p>

          </div>

          {/* Right Column: Interactive Viewfinder Preview Frame */}
          <div className="lg:col-span-6 w-full max-w-lg mx-auto lg:max-w-none animate-blur-in-up delay-250">
            <div
              className={`bg-white/95 backdrop-blur-md rounded-3xl border transition-all duration-500 overflow-hidden shadow-2xl ${
                scanState === 'scanning'
                  ? 'border-[#0066ff] ring-4 ring-blue-500/25 shadow-blue-600/25 scale-[1.01]'
                  : scanState === 'complete'
                  ? 'border-emerald-500/60 ring-4 ring-emerald-500/15 shadow-emerald-600/15'
                  : 'border-slate-200/90 shadow-blue-600/10 hover:border-[#0066ff]/40'
              } group`}
            >
              
              {/* Viewfinder Top Bar */}
              <div className="px-5 py-3.5 bg-slate-50/90 backdrop-blur-sm border-b border-slate-200/70 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className={`w-2.5 h-2.5 rounded-full ${scanState === 'scanning' ? 'bg-[#0066ff] animate-ping' : 'bg-slate-300'}`}></span>
                  <span className="w-2.5 h-2.5 rounded-full bg-slate-300"></span>
                  <span className="w-2.5 h-2.5 rounded-full bg-slate-300"></span>
                </div>
                <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-slate-600">
                  <Scan size={14} className="text-[#0066ff]" />
                  <span>
                    {scanState === 'complete'
                      ? 'Classification Result'
                      : activePlaceholderTab === 'camera'
                      ? 'Live Viewfinder'
                      : 'Image Upload Preview'}
                  </span>
                </div>
                <div
                  className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-bold uppercase tracking-wider transition-colors ${
                    scanState === 'scanning'
                      ? 'bg-blue-100 text-[#0066ff] border border-blue-300'
                      : scanState === 'complete'
                      ? 'bg-emerald-100 text-emerald-700 border border-emerald-300'
                      : 'bg-blue-50 border border-blue-200 text-[#0066ff]'
                  }`}
                >
                  <span className={`w-1.5 h-1.5 rounded-full mr-0.5 ${scanState === 'complete' ? 'bg-emerald-600' : 'bg-[#0066ff] animate-ping'}`}></span>
                  {scanState === 'scanning' ? 'Scanning...' : scanState === 'complete' ? 'Analyzed' : 'Ready'}
                </div>
              </div>

              {/* Viewfinder Viewport */}
              <div className="relative min-h-[320px] sm:min-h-[350px] bg-slate-50/70 backdrop-blur-sm p-6 sm:p-8 flex flex-col items-center justify-center text-center select-none overflow-hidden">
                
                {/* Geometric Corner Guides with Active Laser Reticles */}
                <div className={`absolute top-5 left-5 w-7 h-7 border-t-2 border-l-2 rounded-tl-lg pointer-events-none transition-all duration-300 ${scanState === 'scanning' ? 'border-[#0066ff] scale-110' : 'border-[#0066ff]'}`} />
                <div className={`absolute top-5 right-5 w-7 h-7 border-t-2 border-r-2 rounded-tr-lg pointer-events-none transition-all duration-300 ${scanState === 'scanning' ? 'border-[#0066ff] scale-110' : 'border-[#0066ff]'}`} />
                <div className={`absolute bottom-5 left-5 w-7 h-7 border-b-2 border-l-2 rounded-bl-lg pointer-events-none transition-all duration-300 ${scanState === 'scanning' ? 'border-[#0066ff] scale-110' : 'border-[#0066ff]'}`} />
                <div className={`absolute bottom-5 right-5 w-7 h-7 border-b-2 border-r-2 rounded-br-lg pointer-events-none transition-all duration-300 ${scanState === 'scanning' ? 'border-[#0066ff] scale-110' : 'border-[#0066ff]'}`} />

                {/* Laser Scan line overlay: Visible & sweeping in idle/scanning, disappears when complete */}
                {scanState !== 'complete' && (
                  <div
                    className={`absolute inset-x-4 bg-gradient-to-r from-transparent via-[#0066ff] to-transparent pointer-events-none transition-all duration-500 ${
                      scanState === 'scanning'
                        ? 'h-1 opacity-100 shadow-[0_0_24px_#0066ff] animate-laser-fast'
                        : 'h-0.5 opacity-75 shadow-[0_0_14px_#0066ff] animate-laser'
                    }`}
                  />
                )}

                {/* STATE 1: SCANNING ACTIVE SIMULATION */}
                {scanState === 'scanning' && (
                  <div className="flex flex-col items-center justify-center animate-blur-in w-full max-w-sm">
                    <div className="w-20 h-20 rounded-3xl bg-blue-50 border-2 border-[#0066ff] shadow-xl shadow-blue-500/25 flex items-center justify-center text-[#0066ff] mb-5 animate-pulse">
                      <Scan size={40} className="animate-spin text-[#0066ff]" />
                    </div>
                    <h3 className="font-heading font-black text-lg text-slate-900 uppercase tracking-tight mb-2">
                      Inference in Progress
                    </h3>
                    <p className="font-sans text-xs text-blue-600 font-semibold mb-4 animate-pulse">
                      {scanStepText}
                    </p>
                    <div className="w-48 h-1.5 rounded-full bg-blue-100 overflow-hidden">
                      <div className="h-full bg-[#0066ff] rounded-full animate-pulse w-full" />
                    </div>
                  </div>
                )}

                {/* STATE 2: COMPLETE RESULT CARD */}
                {scanState === 'complete' && (
                  <div className="flex flex-col items-center justify-center animate-blur-in w-full max-w-sm py-2">
                    <div className="w-16 h-16 rounded-2xl bg-emerald-50 border border-emerald-200 shadow-md flex items-center justify-center text-emerald-600 mb-3 animate-bounce">
                      <CheckCircle2 size={34} />
                    </div>

                    <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-bold uppercase tracking-wider mb-2 border border-emerald-200">
                      <span>Grade A &bull; Fresh</span>
                    </div>

                    <h3 className="font-heading font-black text-xl text-slate-900 uppercase tracking-tight mb-1">
                      Bangus (Milkfish)
                    </h3>

                    <p className="font-sans text-xs text-slate-500 mb-4">
                      Pupil Clarity: <strong className="text-slate-800">Clear (98%)</strong> &bull; Gill Tint: <strong className="text-slate-800">Vivid Red (96%)</strong>
                    </p>

                    {/* Confidence Bar */}
                    <div className="w-full bg-white rounded-2xl border border-slate-200 p-3 mb-4 shadow-xs">
                      <div className="flex items-center justify-between text-xs font-bold text-slate-700 mb-1.5">
                        <span>AI Confidence Rating</span>
                        <span className="text-[#0066ff] font-mono">97.4%</span>
                      </div>
                      <div className="w-full h-2 rounded-full bg-slate-100 overflow-hidden">
                        <div className="h-full bg-emerald-500 rounded-full" style={{ width: '97.4%' }} />
                      </div>
                    </div>

                    <button
                      onClick={handleResetScan}
                      className="inline-flex items-center gap-1.5 px-4 py-2 rounded-full bg-slate-900 hover:bg-black text-white text-xs font-bold uppercase tracking-wider transition-colors shadow-xs cursor-pointer"
                    >
                      <RotateCcw size={13} />
                      <span>Scan Another Sample</span>
                    </button>
                  </div>
                )}

                {/* STATE 3: IDLE STATE */}
                {scanState === 'idle' && (
                  <>
                    <div className="w-18 h-18 rounded-2xl bg-white border border-slate-200 shadow-md flex items-center justify-center text-[#0066ff] mb-4 transition-all duration-300 group-hover:scale-105 group-hover:shadow-lg group-hover:shadow-blue-500/20">
                      {activePlaceholderTab === 'camera' ? (
                        <Camera size={34} />
                      ) : (
                        <Upload size={34} />
                      )}
                    </div>

                    <h2 className="font-heading font-extrabold text-base sm:text-lg text-slate-900 mb-1 tracking-tight">
                      {activePlaceholderTab === 'camera'
                        ? 'Live Camera Viewfinder'
                        : 'Image Upload Area'}
                    </h2>
                    <p className="font-sans text-xs text-slate-500 max-w-xs mb-5 leading-relaxed">
                      Click <strong className="text-[#0066ff]">Try Live Scanner</strong> or switch modes to test simulated freshness classification.
                    </p>

                    {/* Switch Modes */}
                    <div className="inline-flex p-1 rounded-full bg-white border border-slate-200 shadow-sm backdrop-blur-xs">
                      <button
                        onClick={() => setActivePlaceholderTab('camera')}
                        className={`inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-bold uppercase tracking-wider transition-all cursor-pointer ${
                          activePlaceholderTab === 'camera'
                            ? 'bg-[#0066ff] text-white shadow-xs'
                            : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
                        }`}
                      >
                        <Camera size={13} /> Camera
                      </button>
                      <button
                        onClick={() => setActivePlaceholderTab('upload')}
                        className={`inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-bold uppercase tracking-wider transition-all cursor-pointer ${
                          activePlaceholderTab === 'upload'
                            ? 'bg-[#0066ff] text-white shadow-xs'
                            : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
                        }`}
                      >
                        <Upload size={13} /> Upload File
                      </button>
                    </div>
                  </>
                )}

              </div>

              {/* Viewfinder Spec Bar */}
              <div className="px-5 py-3.5 bg-white/95 border-t border-slate-100 grid grid-cols-3 divide-x divide-slate-100 text-center">
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Target</p>
                  <p className="font-heading text-xs font-bold text-slate-800 flex items-center justify-center gap-1">
                    <Eye size={12} className="text-[#0066ff]" />
                    Eyes / Gills
                  </p>
                </div>
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Model</p>
                  <p className="font-heading text-xs font-bold text-slate-800 flex items-center justify-center gap-1">
                    <Sparkles size={12} className="text-[#0066ff]" />
                    FreshVision v1
                  </p>
                </div>
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Telemetry</p>
                  <p className="font-heading text-xs font-bold text-[#0066ff] flex items-center justify-center gap-1">
                    <Activity size={12} />
                    &lt; 300ms
                  </p>
                </div>
              </div>

            </div>
          </div>

        </div>

      </div>
    </section>
  );
};

export default Hero;
