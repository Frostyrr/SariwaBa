import React from "react";
import { Link } from "react-router-dom";
import { Button } from "../../../components/ui/Button";
import { Users, Sparkles, ArrowRight, Camera } from "lucide-react";
import { useScrollReveal } from "../../../hooks/useScrollReveal";

export const CommunityCTA: React.FC = () => {
  const { ref: sectionRef, isVisible } = useScrollReveal<HTMLElement>({
    threshold: 0.15,
    rootMargin: "0px 0px -40px 0px",
  });

  const scrollToHero = () => {
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  return (
    <section
      id="community"
      ref={sectionRef}
      className="py-20 md:py-28 bg-[#fbfbfb] relative overflow-hidden scroll-mt-16"
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Main Dark Glass Banner */}
        <div
          className={`relative bg-[#0c0d0e] text-white rounded-3xl border border-slate-800 p-8 sm:p-12 lg:p-16 overflow-hidden shadow-2xl shadow-blue-950/20 transition-all duration-700 ease-out ${
            isVisible
              ? "opacity-100 filter-none translate-y-0 scale-100"
              : "opacity-0 filter blur-md translate-y-10 scale-[0.98]"
          }`}
        >
          {/* Ambient Radial Blur Halos Inside Banner */}
          <div className="absolute -top-24 -right-24 w-96 h-96 bg-[#0066ff]/20 rounded-full blur-3xl pointer-events-none -z-10 animate-ambient-glow" />
          <div className="absolute -bottom-24 -left-24 w-96 h-96 bg-blue-600/15 rounded-full blur-3xl pointer-events-none -z-10 animate-ambient-glow delay-500" />

          {/* Grid Background Pattern */}
          <div className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff08_1px,transparent_1px),linear-gradient(to_bottom,#ffffff08_1px,transparent_1px)] bg-[size:28px_28px] pointer-events-none" />

          <div className="relative z-10 flex flex-col lg:flex-row lg:items-center justify-between gap-10">
            {/* Left Content */}
            <div className="max-w-2xl">
              <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-blue-500/10 border border-blue-500/30 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-5 shadow-xs">
                <Users size={13} className="text-[#0066ff]" />
                <span>Join The Community</span>
              </div>

              <h2 className="font-heading font-black text-3xl sm:text-4xl lg:text-5xl uppercase tracking-tight text-white mb-4 leading-tight">
                Empowering Seafood{" "}
                <span className="text-[#0066ff]">Transparency</span>
              </h2>

              <p className="font-sans text-sm sm:text-base text-slate-400 leading-relaxed mb-8 max-w-xl">
                Join seafood vendors, fisheries, culinary professionals, and
                consumers building an objective, accessible quality standard
                across markets.
              </p>

              {/* Action Buttons */}
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
                <Link to="/register" className="w-full sm:w-auto">
                  <Button
                    variant="primary"
                    size="lg"
                    className="w-full sm:w-auto shadow-lg shadow-blue-600/30 hover:shadow-blue-600/50"
                    icon={<Sparkles size={16} />}
                  >
                    Get Started
                  </Button>
                </Link>

                <button
                  onClick={scrollToHero}
                  className="inline-flex items-center justify-center gap-2 py-3 px-6 rounded-2xl bg-white/10 hover:bg-white/15 border border-white/15 text-white font-heading text-xs font-bold uppercase tracking-wider transition-colors cursor-pointer group"
                >
                  <Camera size={15} className="text-[#0066ff]" />
                  <span>Try Live Scanner</span>
                  <ArrowRight
                    size={14}
                    className="transition-transform group-hover:translate-x-1"
                  />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default CommunityCTA;
