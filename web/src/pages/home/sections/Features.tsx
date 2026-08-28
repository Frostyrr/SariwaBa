import React, { useRef, useState, useEffect } from 'react';
import {
  Zap,
  Eye,
  ShieldCheck,
  Fish,
  Sparkles,
  FileText,
  CheckCircle2,
  Scan,
} from 'lucide-react';

export const Features: React.FC = () => {
  const sectionRef = useRef<HTMLElement | null>(null);
  const trackRef = useRef<HTMLDivElement | null>(null);
  const [scrollProgress, setScrollProgress] = useState(0);
  const [translateX, setTranslateX] = useState(0);
  const [isEntered, setIsEntered] = useState(false);

  const featureList = [
    {
      icon: <Zap size={28} />,
      title: 'Instant AI Inference',
      tag: 'Under 300ms',
      description:
        'High-speed deep learning models process camera frames or image uploads for immediate real-time freshness classification.',
      metric: '< 300ms Response',
      step: '01',
      delayStyle: '100ms',
    },
    {
      icon: <Eye size={28} />,
      title: 'Sensory Eye & Gill Analysis',
      tag: 'Computer Vision',
      description:
        'Specialized neural filters evaluate pupil clarity, corneal clouding, and branchial redness pigmentation.',
      metric: 'Dual-Region Inspection',
      step: '02',
      delayStyle: '180ms',
    },
    {
      icon: <ShieldCheck size={28} />,
      title: 'Standardized Quality Index',
      tag: 'Objective Scoring',
      description:
        'Generates objective freshness classifications (Fresh, Moderately Fresh, Spoiled) with confidence percentages.',
      metric: '96.8% Model Confidence',
      step: '03',
      delayStyle: '260ms',
    },
    {
      icon: <Fish size={28} />,
      title: 'Multi-Species Adaptability',
      tag: 'Marine & Freshwater',
      description:
        'Trained on diverse commercial fish specimens including Bangus, Galunggong, Tilapia, and Tambakol with continuous retraining.',
      metric: 'Expanding Species DB',
      step: '04',
      delayStyle: '340ms',
    },
    {
      icon: <Sparkles size={28} />,
      title: 'Zero Friction Guest Access',
      tag: 'Instant Demo',
      description:
        'Inspect seafood freshness directly from any modern mobile or desktop browser without mandatory account sign-up.',
      metric: '1-Click Evaluation',
      step: '05',
      delayStyle: '420ms',
    },
    {
      icon: <FileText size={28} />,
      title: 'Permanent History & Audit Logs',
      tag: 'Cloud Preserved',
      description:
        'Maintain a chronological log of all classification sessions with inspection time, species, confidence, and visual markers.',
      metric: 'Full Audit Trail',
      step: '06',
      delayStyle: '500ms',
    },
  ];

  // Scroll tracking and entrance animation trigger
  useEffect(() => {
    const handleScroll = () => {
      const section = sectionRef.current;
      const track = trackRef.current;
      if (!section || !track) return;

      const rect = section.getBoundingClientRect();
      const viewportHeight = window.innerHeight;
      const totalScrollableDistance = section.offsetHeight - viewportHeight;

      // Trigger entrance animation when the top of the section enters the viewport
      if (rect.top < viewportHeight * 0.85 && rect.bottom > 0) {
        setIsEntered(true);
      } else if (rect.top > viewportHeight) {
        setIsEntered(false);
      }

      if (totalScrollableDistance <= 0) return;

      // Calculate how far we've scrolled inside the pinned section (0 to 1)
      const scrolledInside = -rect.top;
      const progress = Math.min(Math.max(scrolledInside / totalScrollableDistance, 0), 1);

      setScrollProgress(progress * 100);

      // Total horizontal distance the track needs to travel to show all cards
      const maxHorizontalShift = track.scrollWidth - window.innerWidth + (window.innerWidth > 768 ? 160 : 48);
      
      if (maxHorizontalShift > 0) {
        setTranslateX(progress * maxHorizontalShift);
      }
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    window.addEventListener('resize', handleScroll, { passive: true });
    handleScroll();

    return () => {
      window.removeEventListener('scroll', handleScroll);
      window.removeEventListener('resize', handleScroll);
    };
  }, []);

  return (
    <section
      id="features"
      ref={sectionRef}
      className="relative h-[280vh] bg-[#fbfbfb] border-b border-slate-200/80"
    >
      {/* Pinned Sticky Viewport: Locks in screen and translates horizontally as page scrolls */}
      <div className="sticky top-0 h-screen w-full flex flex-col justify-between py-12 md:py-16 overflow-hidden select-none">
        
        {/* Ambient Blur Halos */}
        <div className="absolute top-1/3 left-1/4 w-[500px] h-[500px] bg-blue-500/6 rounded-full blur-3xl pointer-events-none -z-10 animate-ambient-glow" />
        <div className="absolute bottom-1/4 right-1/4 w-[500px] h-[500px] bg-indigo-500/6 rounded-full blur-3xl pointer-events-none -z-10 animate-ambient-glow delay-500" />

        {/* Section Header with Welcoming Blur-in Entrance */}
        <div className="max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 shrink-0">
          <div
            className={`max-w-3xl transition-all duration-700 ease-out ${
              isEntered
                ? 'opacity-100 filter-none translate-y-0'
                : 'opacity-0 filter blur-md translate-y-8'
            }`}
          >
            <div className="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full bg-blue-50/90 backdrop-blur-xs border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-3 shadow-xs">
              <Scan size={13} />
              <span>Core Capabilities</span>
            </div>
            <h2 className="font-heading font-black text-3xl sm:text-4xl lg:text-5xl text-slate-950 uppercase tracking-tight mb-2">
              Powerful AI <span className="text-[#0066ff]">Features</span>
            </h2>
            <p className="font-sans text-sm sm:text-base text-slate-600 leading-relaxed max-w-2xl">
              Advanced machine vision designed to make seafood quality control fast, reliable, and accessible anywhere.
            </p>
          </div>
        </div>

        {/* Horizontally Pinned Sliding Track with Staggered Entrance Reveal */}
        <div className="relative w-full my-auto py-4 overflow-hidden">
          
          {/* Subtle Edge Overflows */}
          <div className="absolute left-0 inset-y-0 w-12 sm:w-24 bg-gradient-to-r from-[#fbfbfb] to-transparent z-10 pointer-events-none" />
          <div className="absolute right-0 inset-y-0 w-12 sm:w-24 bg-gradient-to-l from-[#fbfbfb] to-transparent z-10 pointer-events-none" />

          <div
            ref={trackRef}
            className="flex gap-6 sm:gap-8 px-6 sm:px-12 lg:px-16 w-max will-change-transform transition-transform duration-75 ease-out"
            style={{
              transform: `translate3d(-${translateX}px, 0, 0)`,
            }}
          >
            {featureList.map((item, index) => (
              <div
                key={index}
                style={{
                  transitionDelay: isEntered ? item.delayStyle : '0ms',
                }}
                className={`w-[310px] sm:w-[360px] md:w-[410px] shrink-0 bg-white/95 backdrop-blur-md rounded-3xl border border-slate-200/90 p-7 sm:p-8 flex flex-col justify-between transition-all duration-700 ease-out hover:shadow-2xl hover:shadow-blue-600/12 hover:border-[#0066ff]/50 hover:-translate-y-2 group shadow-sm ${
                  isEntered
                    ? 'opacity-100 filter-none translate-y-0 scale-100'
                    : 'opacity-0 filter blur-sm translate-y-12 scale-[0.95]'
                }`}
              >
                <div>
                  {/* Card Top */}
                  <div className="flex items-center justify-between mb-6">
                    <div className="w-14 h-14 rounded-2xl bg-blue-50/90 backdrop-blur-xs border border-blue-100 group-hover:bg-[#0066ff] group-hover:border-[#0066ff] text-[#0066ff] group-hover:text-white flex items-center justify-center transition-all duration-300 shadow-xs group-hover:shadow-md group-hover:shadow-blue-500/30 group-hover:scale-105">
                      {item.icon}
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-[11px] font-heading font-bold uppercase tracking-wider px-3 py-1 rounded-full bg-slate-50 border border-slate-200 text-slate-600 group-hover:border-blue-200 group-hover:text-[#0066ff] transition-colors">
                        {item.tag}
                      </span>
                      <span className="text-xs font-mono font-bold text-slate-300">
                        {item.step}
                      </span>
                    </div>
                  </div>

                  {/* Card Headline */}
                  <h3 className="font-heading font-black text-xl text-slate-900 uppercase tracking-tight mb-3 group-hover:text-[#0066ff] transition-colors">
                    {item.title}
                  </h3>

                  {/* Card Description */}
                  <p className="font-sans text-sm text-slate-500 leading-relaxed">
                    {item.description}
                  </p>
                </div>

                {/* Card Footer Metric */}
                <div className="mt-8 pt-4 border-t border-slate-100 flex items-center justify-between text-xs font-bold uppercase tracking-wider text-slate-600">
                  <span className="flex items-center gap-1.5 text-emerald-600">
                    <CheckCircle2 size={14} />
                    Active Model
                  </span>
                  <span className="font-mono text-[#0066ff] bg-blue-50/80 px-2.5 py-1 rounded-md border border-blue-100/80">
                    {item.metric}
                  </span>
                </div>
              </div>
            ))}
          </div>

        </div>

        {/* Minimal Progress Bar pinned to bottom with entrance animation */}
        <div className="max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 shrink-0">
          <div
            style={{
              transitionDelay: isEntered ? '400ms' : '0ms',
            }}
            className={`w-full max-w-sm h-1.5 rounded-full bg-slate-200/80 overflow-hidden transition-all duration-700 ease-out ${
              isEntered ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
            }`}
          >
            <div
              className="h-full bg-[#0066ff] rounded-full transition-all duration-100 ease-out"
              style={{ width: `${Math.max(12, scrollProgress)}%` }}
            />
          </div>
        </div>

      </div>
    </section>
  );
};

export default Features;
