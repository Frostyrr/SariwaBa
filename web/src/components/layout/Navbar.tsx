import React, { useState } from "react";
import { Link, useNavigate, useLocation } from "react-router-dom";
import { Button } from "../ui/Button";
import { Sparkles, Menu, X, LogIn } from "lucide-react";

export const Navbar: React.FC = () => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const scrollToSection = (id: string) => {
    setMobileMenuOpen(false);

    const performScroll = () => {
      if (id === "hero") {
        window.scrollTo({ top: 0, behavior: "smooth" });
        return;
      }

      const element = document.getElementById(id);
      if (element) {
        const navbar = document.querySelector("header");
        const navbarHeight = navbar ? navbar.offsetHeight : 70;
        const elementPosition =
          element.getBoundingClientRect().top + window.scrollY;
        const offsetPosition = elementPosition - navbarHeight;

        window.scrollTo({
          top: Math.max(0, offsetPosition),
          behavior: "smooth",
        });
      }
    };

    if (location.pathname !== "/") {
      navigate("/");
      setTimeout(performScroll, 120);
    } else {
      performScroll();
    }
  };

  return (
    <header className="sticky top-0 z-50 w-full bg-[#fbfbfb]/85 backdrop-blur-md border-b border-slate-200/80">
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
        {/* Brand Logo & Title */}
        <Link
          to="/"
          className="flex items-center gap-3 cursor-pointer select-none group"
          onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })}
        >
          <img
            src="/SariwaBaLogo.png"
            alt="SariwaBa Logo"
            className="w-9 h-9 object-contain rounded-lg transition-transform duration-200 group-hover:scale-105"
          />
          <div className="flex flex-col text-left">
            <span className="font-heading font-black text-xl sm:text-2xl text-slate-950 uppercase tracking-tight leading-none">
              Sariwa<span className="text-[#0066ff]">Ba?</span>
            </span>
          </div>
        </Link>

        {/* Desktop Navigation Links - Symph Upper Small Style */}
        <div className="hidden md:flex items-center gap-8 text-xs font-bold uppercase tracking-wider text-slate-700">
          <a
            href="#hero"
            onClick={(e) => {
              e.preventDefault();
              scrollToSection("hero");
            }}
            className="hover:text-[#0066ff] transition-colors"
          >
            Home
          </a>
          <a
            href="#history"
            onClick={(e) => {
              e.preventDefault();
              scrollToSection("history");
            }}
            className="hover:text-[#0066ff] transition-colors"
          >
            History
          </a>
          <a
            href="#features"
            onClick={(e) => {
              e.preventDefault();
              scrollToSection("features");
            }}
            className="hover:text-[#0066ff] transition-colors"
          >
            Features
          </a>
          <a
            href="#how-it-works"
            onClick={(e) => {
              e.preventDefault();
              scrollToSection("how-it-works");
            }}
            className="hover:text-[#0066ff] transition-colors"
          >
            How It Works
          </a>
        </div>

        {/* Action Buttons: Log In & Try Classifier */}
        <div className="hidden md:flex items-center gap-3">
          <Link to="/login">
            <Button variant="ghost" size="sm" icon={<LogIn size={15} />}>
              Log In
            </Button>
          </Link>
          <Button
            variant="primary"
            size="sm"
            icon={<Sparkles size={14} />}
            onClick={() => scrollToSection("hero")}
          >
            Try Classifier
          </Button>
        </div>

        {/* Mobile Hamburger Toggle */}
        <button
          className="md:hidden flex items-center justify-center p-2 text-slate-800 rounded-lg hover:bg-slate-100 transition-colors cursor-pointer"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          aria-label="Toggle navigation menu"
        >
          {mobileMenuOpen ? <X size={22} /> : <Menu size={22} />}
        </button>
      </nav>

      {/* Mobile Menu Drawer */}
      {mobileMenuOpen && (
        <div className="md:hidden flex flex-col px-6 py-5 bg-white border-b border-slate-200 space-y-3">
          <a
            href="#hero"
            onClick={(e) => {
              e.preventDefault();
              scrollToSection("hero");
            }}
            className="text-xs font-bold uppercase tracking-wider text-slate-800 py-2 border-b border-slate-100"
          >
            Home
          </a>
          <a
            href="#features"
            onClick={(e) => {
              e.preventDefault();
              scrollToSection("features");
            }}
            className="text-xs font-bold uppercase tracking-wider text-slate-800 py-2 border-b border-slate-100"
          >
            Features
          </a>
          <a
            href="#how-it-works"
            onClick={(e) => {
              e.preventDefault();
              scrollToSection("how-it-works");
            }}
            className="text-xs font-bold uppercase tracking-wider text-slate-800 py-2 border-b border-slate-100"
          >
            How It Works
          </a>
          <a
            href="#history"
            onClick={(e) => {
              e.preventDefault();
              scrollToSection("history");
            }}
            className="text-xs font-bold uppercase tracking-wider text-slate-800 py-2 border-b border-slate-100"
          >
            History
          </a>
          <div className="pt-2 flex flex-col gap-2">
            <Link to="/login" onClick={() => setMobileMenuOpen(false)}>
              <Button
                variant="outline"
                size="md"
                fullWidth
                icon={<LogIn size={15} />}
              >
                Log In
              </Button>
            </Link>
            <Button
              variant="primary"
              size="md"
              fullWidth
              icon={<Sparkles size={15} />}
              onClick={() => scrollToSection("hero")}
            >
              Try Classifier
            </Button>
          </div>
        </div>
      )}
    </header>
  );
};
