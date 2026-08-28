import React from 'react';
import { Zap, Eye, ShieldCheck, Fish, Sparkles, FileText } from 'lucide-react';

export const Features: React.FC = () => {
  const featureList = [
    {
      icon: <Zap size={24} />,
      title: 'Instant AI Inference',
      description:
        'High-speed deep learning models process image inputs in under 300ms for rapid on-site quality evaluation.',
    },
    {
      icon: <Eye size={24} />,
      title: 'Sensory Eye & Gill Analysis',
      description:
        'Specialized computer vision filters assess pupil clarity, corneal clouding, and branchial redness pigmentation.',
    },
    {
      icon: <ShieldCheck size={24} />,
      title: 'Standardized Quality Grading',
      description:
        'Generates objective freshness classifications (Fresh, Moderately Fresh, Spoiled) with confidence metrics.',
    },
    {
      icon: <Fish size={24} />,
      title: 'Multi-Species Adaptability',
      description:
        'Trained on diverse marine and freshwater fish varieties to ensure high detection accuracy across specimens.',
    },
    {
      icon: <Sparkles size={24} />,
      title: 'No Sign-In Required',
      description:
        'Instantly evaluate seafood quality directly through browser camera or photo upload with zero friction.',
    },
    {
      icon: <FileText size={24} />,
      title: 'Scan History & Logs',
      description:
        'Maintain an organized chronological log of all your visual classification tries with timestamps and grades.',
    },
  ];

  return (
    <section id="features" className="py-20 md:py-28 bg-[#fbfbfb] relative border-b border-slate-200/80">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header */}
        <div className="text-center max-w-2xl mx-auto mb-16">
          <div className="inline-flex items-center px-3.5 py-1 rounded-full bg-blue-50 border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-4">
            <span>Capabilities</span>
          </div>
          <h2 className="font-heading font-black text-3xl sm:text-4xl lg:text-5xl text-slate-950 uppercase tracking-tight mb-4">
            Powerful AI Features
          </h2>
          <p className="font-sans text-base sm:text-lg text-slate-600 leading-relaxed">
            Advanced machine vision designed to make seafood quality control fast, reliable, and accessible anywhere.
          </p>
        </div>

        {/* 6-Card Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8">
          {featureList.map((item, index) => (
            <div
              key={index}
              className="bg-white rounded-3xl border border-slate-200 p-7 sm:p-8 flex flex-col transition-all duration-300 hover:shadow-xl hover:shadow-blue-600/5 hover:border-[#0066ff]/40 group"
            >
              <div className="w-12 h-12 rounded-2xl bg-blue-50 border border-blue-100 group-hover:bg-[#0066ff] group-hover:border-[#0066ff] text-[#0066ff] group-hover:text-white flex items-center justify-center mb-6 transition-colors duration-200 shadow-xs">
                {item.icon}
              </div>
              <h3 className="font-heading font-black text-base sm:text-lg text-slate-900 uppercase tracking-tight mb-2">
                {item.title}
              </h3>
              <p className="font-sans text-xs sm:text-sm text-slate-500 leading-relaxed">
                {item.description}
              </p>
            </div>
          ))}
        </div>

      </div>
    </section>
  );
};

export default Features;
