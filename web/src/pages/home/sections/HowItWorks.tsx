import React from 'react';
import { Camera, Cpu, Award, ArrowRight, Sparkles } from 'lucide-react';
import { useScrollReveal } from '../../../hooks/useScrollReveal';

export const HowItWorks: React.FC = () => {
  const { ref: sectionRef, isVisible } = useScrollReveal<HTMLElement>({
    threshold: 0.15,
    rootMargin: '0px 0px -40px 0px',
  });

  const steps = [
    {
      stepNumber: '01',
      icon: <Camera size={26} />,
      title: 'Capture or upload a fish image',
      description:
        'Take a clear snapshot of the fish using your camera, or upload an existing image from your device gallery.',
      stage: 'Step 1: Input',
      delayStyle: '100ms',
    },
    {
      stepNumber: '02',
      icon: <Cpu size={26} />,
      title: 'AI analyzes the image',
      description:
        'Computer vision neural networks process visual markers such as gill coloration, eye clarity, and skin texture.',
      stage: 'Step 2: Processing',
      delayStyle: '250ms',
    },
    {
      stepNumber: '03',
      icon: <Award size={26} />,
      title: 'View the freshness classification',
      description:
        'Get immediate classification results with freshness grades, confidence ratings, and quality assessment breakdowns.',
      stage: 'Step 3: Results',
      delayStyle: '400ms',
    },
  ];

  return (
    <section
      id="how-it-works"
      ref={sectionRef}
      className="min-h-[calc(100vh-73px)] flex flex-col justify-center py-20 md:py-28 bg-white/80 backdrop-blur-md border-t border-b border-slate-200/80 relative overflow-hidden transition-colors duration-500 scroll-mt-16"
    >
      {/* Ambient Blur Backdrop Glow */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-[650px] h-[340px] bg-blue-500/6 rounded-full blur-3xl pointer-events-none -z-10 animate-ambient-glow" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Header with Welcoming Blur Transition */}
        <div
          className={`text-center max-w-2xl mx-auto mb-16 transition-all duration-700 ease-out ${
            isVisible
              ? 'opacity-100 filter-none translate-y-0'
              : 'opacity-0 filter blur-md translate-y-10'
          }`}
        >
          <div className="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full bg-blue-50/90 backdrop-blur-xs border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-4 shadow-xs">
            <Sparkles size={13} />
            <span>Process Overview</span>
          </div>
          <h2 className="font-heading font-black text-3xl sm:text-4xl lg:text-5xl text-slate-950 uppercase tracking-tight mb-4">
            How SariwaBa Works
          </h2>
          <p className="font-sans text-base sm:text-lg text-slate-600 leading-relaxed">
            Experience effortless seafood quality assessment powered by intelligent computer vision in three straightforward steps.
          </p>
        </div>

        {/* 3 Step Cards Grid with Staggered Welcoming Reveals */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 relative">
          {steps.map((step, index) => (
            <div
              key={index}
              style={{
                transitionDelay: isVisible ? step.delayStyle : '0ms',
              }}
              className={`group relative bg-white/95 backdrop-blur-md rounded-3xl border border-slate-200 hover:border-[#0066ff]/50 p-8 flex flex-col transition-all duration-700 ease-out shadow-sm hover:shadow-2xl hover:shadow-blue-600/10 hover:-translate-y-2 ${
                isVisible
                  ? 'opacity-100 filter-none translate-y-0 scale-100'
                  : 'opacity-0 filter blur-sm translate-y-12 scale-[0.97]'
              }`}
            >
              {/* Card Top */}
              <div className="flex items-center justify-between mb-6">
                <span className="w-12 h-12 rounded-2xl bg-blue-50/90 backdrop-blur-xs border border-blue-200 text-[#0066ff] font-heading font-black text-base flex items-center justify-center shadow-xs">
                  {step.stepNumber}
                </span>
                <div className="w-12 h-12 rounded-2xl bg-slate-50 border border-slate-200 group-hover:bg-[#0066ff] group-hover:border-[#0066ff] text-[#0066ff] group-hover:text-white flex items-center justify-center transition-all duration-300 shadow-xs group-hover:shadow-md group-hover:shadow-blue-500/30 group-hover:scale-105">
                  {step.icon}
                </div>
              </div>

              {/* Card Body */}
              <div className="flex flex-col flex-1">
                <span className="text-[11px] font-bold uppercase tracking-wider text-[#0066ff] mb-2">
                  {step.stage}
                </span>
                <h3 className="font-heading font-extrabold text-lg sm:text-xl text-slate-900 mb-3 leading-snug tracking-tight">
                  {step.title}
                </h3>
                <p className="font-sans text-sm text-slate-600 leading-relaxed">
                  {step.description}
                </p>
              </div>

              {/* Connector Arrow (Desktop only, between steps) */}
              {index < steps.length - 1 && (
                <div className="hidden lg:flex absolute top-1/2 -right-4 -translate-y-1/2 z-10 w-8 h-8 rounded-full bg-white border border-slate-200 text-[#0066ff] items-center justify-center shadow-md transition-transform group-hover:translate-x-1">
                  <ArrowRight size={15} />
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Tip Box with Welcoming Transition */}
        <div
          style={{
            transitionDelay: isVisible ? '500ms' : '0ms',
          }}
          className={`mt-14 text-center p-5 bg-blue-50/70 backdrop-blur-sm border border-dashed border-blue-200/90 rounded-2xl max-w-xl mx-auto transition-all duration-700 ease-out shadow-xs ${
            isVisible
              ? 'opacity-100 filter-none translate-y-0'
              : 'opacity-0 filter blur-sm translate-y-8'
          }`}
        >
          <p className="font-sans text-xs sm:text-sm text-slate-700">
            💡 <strong className="font-semibold text-slate-900">Tip for best results:</strong> Ensure good lighting and keep the fish or key sensory parts (eyes/gills) centered in frame.
          </p>
        </div>

      </div>
    </section>
  );
};

export default HowItWorks;
