import React, { useState } from 'react';
import { Button } from '../../../components/ui/Button';
import { Camera, Upload, Scan, ArrowRight, Check } from 'lucide-react';

export const Hero: React.FC = () => {
  const [activePlaceholderTab, setActivePlaceholderTab] = useState<'camera' | 'upload'>('camera');

  const handleActionClick = (mode: 'camera' | 'upload') => {
    setActivePlaceholderTab(mode);
  };

  return (
    <section id="hero" className="relative pt-10 pb-16 md:pt-16 md:pb-24 overflow-hidden">
      
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

            {/* CTA Buttons in Symph Style */}
            <div className="flex flex-col sm:flex-row items-center gap-4 sm:gap-6 w-full sm:w-auto mb-6 animate-blur-in-up delay-300">
              <Button
                variant="primary"
                size="lg"
                className="w-full sm:w-auto shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40 transition-all"
                icon={<Camera size={18} />}
                onClick={() => handleActionClick('camera')}
              >
                Open Camera
              </Button>
              <button
                onClick={() => handleActionClick('upload')}
                className="inline-flex items-center gap-2 text-sm font-bold uppercase tracking-wider text-slate-800 hover:text-[#0066ff] py-2 px-4 transition-colors cursor-pointer group"
              >
                <Upload size={16} className="text-[#0066ff]" />
                <span>Upload Image</span>
                <ArrowRight size={16} className="transition-transform group-hover:translate-x-1" />
              </button>
            </div>

            {/* Helper Micro-copy */}
            <p className="text-xs font-medium text-slate-400 flex items-center gap-1.5 animate-blur-in-up delay-400">
              <Check size={14} className="text-[#0066ff]" />
              <span>Try the classification without an account &mdash; instant demo</span>
            </p>

          </div>

          {/* Right Column: Viewfinder Preview Frame with Blur Resolution */}
          <div className="lg:col-span-6 w-full max-w-lg mx-auto lg:max-w-none animate-blur-in-up delay-250">
            <div className="bg-white/95 backdrop-blur-md rounded-3xl border border-slate-200/90 shadow-2xl shadow-blue-600/10 overflow-hidden transition-all duration-300 hover:border-[#0066ff]/40 group">
              
              {/* Viewfinder Top Bar */}
              <div className="px-5 py-3.5 bg-slate-50/90 backdrop-blur-sm border-b border-slate-200/70 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full bg-slate-300"></span>
                  <span className="w-2.5 h-2.5 rounded-full bg-slate-300"></span>
                  <span className="w-2.5 h-2.5 rounded-full bg-slate-300"></span>
                </div>
                <div className="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-slate-600">
                  <Scan size={14} className="text-[#0066ff]" />
                  <span>{activePlaceholderTab === 'camera' ? 'Camera Preview' : 'Image Upload Preview'}</span>
                </div>
                <div className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-blue-50 border border-blue-200 text-[#0066ff] text-[11px] font-bold uppercase tracking-wider">
                  <span className="w-1.5 h-1.5 rounded-full bg-[#0066ff] animate-ping mr-0.5"></span>
                  Ready
                </div>
              </div>

              {/* Viewfinder Viewport */}
              <div className="relative min-h-[300px] sm:min-h-[340px] bg-slate-50/60 backdrop-blur-sm p-6 sm:p-8 flex flex-col items-center justify-center text-center select-none overflow-hidden">
                
                {/* Geometric Corner Guides */}
                <div className="absolute top-5 left-5 w-7 h-7 border-t-2 border-l-2 border-[#0066ff] rounded-tl-lg pointer-events-none transition-transform group-hover:scale-105" />
                <div className="absolute top-5 right-5 w-7 h-7 border-t-2 border-r-2 border-[#0066ff] rounded-tr-lg pointer-events-none transition-transform group-hover:scale-105" />
                <div className="absolute bottom-5 left-5 w-7 h-7 border-b-2 border-l-2 border-[#0066ff] rounded-bl-lg pointer-events-none transition-transform group-hover:scale-105" />
                <div className="absolute bottom-5 right-5 w-7 h-7 border-b-2 border-r-2 border-[#0066ff] rounded-br-lg pointer-events-none transition-transform group-hover:scale-105" />

                {/* Laser Scan line overlay with dynamic animation */}
                <div className="absolute inset-x-6 h-0.5 bg-gradient-to-r from-transparent via-[#0066ff] to-transparent shadow-[0_0_14px_#0066ff] pointer-events-none animate-laser" />

                {/* Icon Circle */}
                <div className="w-18 h-18 rounded-2xl bg-white border border-slate-200 shadow-md flex items-center justify-center text-[#0066ff] mb-4 transition-all duration-300 group-hover:scale-105 group-hover:shadow-lg group-hover:shadow-blue-500/20">
                  {activePlaceholderTab === 'camera' ? (
                    <Camera size={34} />
                  ) : (
                    <Upload size={34} />
                  )}
                </div>

                <h2 className="font-heading font-extrabold text-base sm:text-lg text-slate-900 mb-1 tracking-tight">
                  {activePlaceholderTab === 'camera'
                    ? 'Camera Viewfinder Scaffold'
                    : 'Image Drop Area Scaffold'}
                </h2>
                <p className="font-sans text-xs text-slate-500 max-w-xs mb-5 leading-relaxed">
                  Position fish eyes, gills, or body within frame to assess freshness.
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
              </div>

              {/* Viewfinder Spec Bar */}
              <div className="px-5 py-3.5 bg-white/95 border-t border-slate-100 grid grid-cols-3 divide-x divide-slate-100 text-center">
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Target</p>
                  <p className="font-heading text-xs font-bold text-slate-800">Eyes / Gills / Flesh</p>
                </div>
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Model</p>
                  <p className="font-heading text-xs font-bold text-slate-800">FreshVision v1</p>
                </div>
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Inference</p>
                  <p className="font-heading text-xs font-bold text-[#0066ff]">&lt; 300ms</p>
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




