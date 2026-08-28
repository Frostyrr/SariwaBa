import React from 'react';
import { ShieldCheck, Heart } from 'lucide-react';

export const Footer: React.FC = () => {
  const currentYear = new Date().getFullYear();

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <footer className="w-full bg-white border-t border-slate-200 mt-auto pt-14 pb-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Main 4-Column Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-12 gap-8 pb-12">
          
          {/* Brand Col */}
          <div className="lg:col-span-4 flex flex-col gap-3">
            <div
              className="flex items-center gap-2.5 cursor-pointer select-none w-fit group"
              onClick={scrollToTop}
            >
              <img
                src="/SariwaBaLogo.png"
                alt="SariwaBa Logo"
                className="w-9 h-9 object-contain rounded-lg transition-transform duration-200 group-hover:scale-105"
              />
              <span className="font-heading font-black text-xl text-slate-950 uppercase tracking-tight leading-none">
                Sariwa<span className="text-[#0066ff]">Ba?</span>
              </span>
            </div>
            <p className="font-sans text-sm text-slate-500 leading-relaxed max-w-sm">
              AI-driven fish freshness classification system powered by deep learning and computer vision.
            </p>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-md bg-blue-50 border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider w-fit mt-1">
              <ShieldCheck size={14} className="text-[#0066ff] shrink-0" />
              <span>Smart Quality Assurance</span>
            </div>
          </div>

          {/* Nav Links */}
          <div className="lg:col-span-2 flex flex-col">
            <h3 className="font-heading font-black text-xs uppercase tracking-wider text-slate-900 mb-4">
              Navigation
            </h3>
            <ul className="space-y-2.5 text-xs font-bold uppercase tracking-wider text-slate-600">
              <li>
                <a href="#hero" className="hover:text-[#0066ff] transition-colors">Home</a>
              </li>
              <li>
                <a href="#features" className="hover:text-[#0066ff] transition-colors">Features</a>
              </li>
              <li>
                <a href="#how-it-works" className="hover:text-[#0066ff] transition-colors">How It Works</a>
              </li>
              <li>
                <a href="#history" className="hover:text-[#0066ff] transition-colors">History</a>
              </li>
            </ul>
          </div>

          {/* System Capabilities */}
          <div className="lg:col-span-3 flex flex-col">
            <h3 className="font-heading font-black text-xs uppercase tracking-wider text-slate-900 mb-4">
              System Features
            </h3>
            <ul className="space-y-2.5 text-sm text-slate-600">
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-[#0066ff]"></span>
                <span>Computer Vision Analysis</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-[#0066ff]"></span>
                <span>Gill & Eye Inspection</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-[#0066ff]"></span>
                <span>Instant Freshness Grade</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-[#0066ff]"></span>
                <span>No-Account Guest Access</span>
              </li>
            </ul>
          </div>

          {/* Scope Note */}
          <div className="lg:col-span-3 flex flex-col">
            <h3 className="font-heading font-black text-xs uppercase tracking-wider text-slate-900 mb-4">
              Classification Scope
            </h3>
            <p className="font-sans text-xs text-slate-500 leading-relaxed">
              This system provides an AI-assisted visual assessment scaffold for freshness determination. Intended for quality screening and research evaluation.
            </p>
          </div>

        </div>

        {/* Bottom Bar */}
        <div className="pt-6 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-slate-500">
          <p>
            &copy; {currentYear} <strong className="font-semibold text-slate-800">SariwaBa?</strong> Fish Freshness Classification System. All rights reserved.
          </p>
          <div className="flex items-center gap-1.5 text-slate-500">
            <span>Built for seafood quality assurance</span>
            <Heart size={13} className="text-[#0066ff] fill-[#0066ff]" />
          </div>
        </div>

      </div>
    </footer>
  );
};

export default Footer;


