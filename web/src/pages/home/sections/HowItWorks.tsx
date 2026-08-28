import React from 'react';
import { Camera, Cpu, Award, ArrowRight } from 'lucide-react';

export const HowItWorks: React.FC = () => {
  const steps = [
    {
      stepNumber: '01',
      icon: <Camera size={26} />,
      title: 'Capture or upload a fish image',
      description:
        'Take a clear snapshot of the fish using your camera, or upload an existing image from your device gallery.',
      stage: 'Step 1: Input',
    },
    {
      stepNumber: '02',
      icon: <Cpu size={26} />,
      title: 'AI analyzes the image',
      description:
        'Computer vision neural networks process visual markers such as gill coloration, eye clarity, and skin texture.',
      stage: 'Step 2: Processing',
    },
    {
      stepNumber: '03',
      icon: <Award size={26} />,
      title: 'View the freshness classification',
      description:
        'Get immediate classification results with freshness grades, confidence ratings, and quality assessment breakdowns.',
      stage: 'Step 3: Results',
    },
  ];

  return (
    <section id="how-it-works" className="py-20 md:py-28 bg-white/70 backdrop-blur-xs border-t border-b border-slate-200/80 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header */}
        <div className="text-center max-w-2xl mx-auto mb-16">
          <div className="inline-flex items-center px-3.5 py-1 rounded-full bg-blue-50 border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-4">
            <span>Process Overview</span>
          </div>
          <h2 className="font-heading font-black text-3xl sm:text-4xl lg:text-5xl text-slate-950 uppercase tracking-tight mb-4">
            How SariwaBa Works
          </h2>
          <p className="font-sans text-base sm:text-lg text-slate-600 leading-relaxed">
            Experience effortless seafood quality assessment powered by intelligent computer vision in three straightforward steps.
          </p>
        </div>

        {/* 3 Step Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 relative">
          {steps.map((step, index) => (
            <div
              key={index}
              className="group relative bg-white rounded-3xl border border-slate-200 hover:border-[#0066ff]/50 p-8 flex flex-col transition-all duration-300 shadow-sm hover:shadow-2xl hover:shadow-blue-600/10 hover:-translate-y-1"
            >
              {/* Card Top */}
              <div className="flex items-center justify-between mb-6">
                <span className="w-12 h-12 rounded-2xl bg-blue-50 border border-blue-200 text-[#0066ff] font-heading font-black text-base flex items-center justify-center">
                  {step.stepNumber}
                </span>
                <div className="w-12 h-12 rounded-2xl bg-slate-50 border border-slate-200 group-hover:bg-[#0066ff] group-hover:border-[#0066ff] text-[#0066ff] group-hover:text-white flex items-center justify-center transition-colors duration-200 shadow-xs">
                  {step.icon}
                </div>
              </div>

              {/* Card Body */}
              <div className="flex flex-col flex-1">
                <span className="text-[11px] font-bold uppercase tracking-wider text-[#0066ff] mb-2">
                  {step.stage}
                </span>
                <h3 className="font-heading font-extrabold text-lg text-slate-900 mb-3 leading-snug tracking-tight">
                  {step.title}
                </h3>
                <p className="font-sans text-sm text-slate-600 leading-relaxed">
                  {step.description}
                </p>
              </div>

              {/* Connector Arrow (Desktop only, between steps) */}
              {index < steps.length - 1 && (
                <div className="hidden lg:flex absolute top-1/2 -right-4 -translate-y-1/2 z-10 w-8 h-8 rounded-full bg-white border border-slate-200 text-[#0066ff] items-center justify-center shadow-md">
                  <ArrowRight size={15} />
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Tip Box */}
        <div className="mt-12 text-center p-4 sm:p-5 bg-blue-50/50 border border-dashed border-blue-200 rounded-2xl max-w-xl mx-auto">
          <p className="font-sans text-xs sm:text-sm text-slate-700">
            💡 <strong className="font-semibold text-slate-900">Tip for best results:</strong> Ensure good lighting and keep the fish or key sensory parts (eyes/gills) centered in frame.
          </p>
        </div>

      </div>
    </section>
  );
};

