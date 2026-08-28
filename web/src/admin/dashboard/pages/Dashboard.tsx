import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import {
  LayoutDashboard,
  BarChart3,
  Fish,
  Users as UsersIcon,
  ArrowLeft,
  Bell,
  Search,
  Menu,
  X,
  Activity,
  LogOut,
} from 'lucide-react';
import { Overview } from './sections/Overview';
import { Analytics } from './sections/Analytics';
import { Classifications } from './sections/Classifications';
import { Users } from './sections/Users';

type AdminTab = 'overview' | 'analytics' | 'classifications' | 'users';

export const Dashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState<AdminTab>('overview');
  const [mobileSidebarOpen, setMobileSidebarOpen] = useState(false);

  const navItems = [
    {
      id: 'overview' as AdminTab,
      label: 'Overview',
      icon: <LayoutDashboard size={18} />,
    },
    {
      id: 'analytics' as AdminTab,
      label: 'Analytics',
      icon: <BarChart3 size={18} />,
    },
    {
      id: 'classifications' as AdminTab,
      label: 'Classifications',
      icon: <Fish size={18} />,
    },
    {
      id: 'users' as AdminTab,
      label: 'Users Directory',
      icon: <UsersIcon size={18} />,
    },
  ];

  return (
    <div className="min-h-screen bg-[#fbfbfb] flex flex-col md:flex-row antialiased font-sans text-slate-900">
      
      {/* Mobile Top Header */}
      <div className="md:hidden bg-white border-b border-slate-200 px-4 py-3.5 flex items-center justify-between sticky top-0 z-40">
        <Link to="/" className="flex items-center gap-2">
          <img src="/SariwaBaLogo.png" alt="Logo" className="w-8 h-8 object-contain rounded-lg" />
          <span className="font-heading font-black text-lg text-slate-950 uppercase tracking-tight">
            Sariwa<span className="text-[#0066ff]">Ba?</span> <span className="text-xs bg-slate-100 text-slate-600 px-2 py-0.5 rounded-md font-bold">Admin</span>
          </span>
        </Link>
        <button
          onClick={() => setMobileSidebarOpen(!mobileSidebarOpen)}
          className="p-2 rounded-xl border border-slate-200 text-slate-700 hover:bg-slate-50 cursor-pointer"
        >
          {mobileSidebarOpen ? <X size={20} /> : <Menu size={20} />}
        </button>
      </div>

      {/* Sidebar Navigation */}
      <aside
        className={`fixed md:sticky top-0 left-0 z-40 h-screen w-64 bg-white border-r border-slate-200 flex flex-col justify-between transition-transform duration-300 md:translate-x-0 ${
          mobileSidebarOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        {/* Brand Header */}
        <div>
          <div className="p-6 border-b border-slate-100 flex items-center justify-between">
            <Link to="/" className="flex items-center gap-2.5 group">
              <img
                src="/SariwaBaLogo.png"
                alt="SariwaBa Logo"
                className="w-9 h-9 object-contain rounded-lg transition-transform group-hover:scale-105"
              />
              <div>
                <span className="font-heading font-black text-xl text-slate-950 uppercase tracking-tight block leading-none">
                  Sariwa<span className="text-[#0066ff]">Ba?</span>
                </span>
                <span className="text-[10px] font-heading font-bold uppercase tracking-wider text-slate-400">
                  Admin Workspace
                </span>
              </div>
            </Link>
          </div>

          {/* Navigation Links */}
          <nav className="p-4 space-y-1.5">
            <div className="px-3 py-2 text-[10px] font-heading font-bold uppercase tracking-wider text-slate-400">
              Management
            </div>
            {navItems.map((item) => {
              const isActive = activeTab === item.id;
              return (
                <button
                  key={item.id}
                  onClick={() => {
                    setActiveTab(item.id);
                    setMobileSidebarOpen(false);
                  }}
                  className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-2xl font-heading text-xs font-bold uppercase tracking-wider transition-all cursor-pointer ${
                    isActive
                      ? 'bg-[#0066ff] text-white shadow-md shadow-blue-500/20'
                      : 'text-slate-600 hover:bg-slate-50 hover:text-slate-950'
                  }`}
                >
                  <span className={isActive ? 'text-white' : 'text-slate-400 group-hover:text-slate-700'}>
                    {item.icon}
                  </span>
                  <span>{item.label}</span>
                </button>
              );
            })}
          </nav>
        </div>

        {/* Sidebar Footer: Back to App & Admin Profile */}
        <div className="p-4 border-t border-slate-100 space-y-3">
          <Link
            to="/"
            className="flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-bold uppercase tracking-wider text-slate-500 hover:text-slate-900 hover:bg-slate-50 transition-colors"
          >
            <ArrowLeft size={16} />
            <span>Public App</span>
          </Link>

          <div className="p-3 rounded-2xl bg-slate-50 border border-slate-200/80 flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-xl bg-slate-900 text-white flex items-center justify-center font-heading font-black text-xs">
                A
              </div>
              <div className="overflow-hidden">
                <p className="font-heading font-bold text-xs text-slate-900 truncate">Admin Lead</p>
                <p className="text-[10px] text-slate-400 truncate">admin@sariwaba.ph</p>
              </div>
            </div>
            <Link to="/login" title="Sign out" className="text-slate-400 hover:text-slate-700 p-1">
              <LogOut size={15} />
            </Link>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 flex flex-col min-h-screen overflow-x-hidden">
        
        {/* Top Desktop App Bar */}
        <header className="bg-white/80 backdrop-blur-md border-b border-slate-200/80 px-6 sm:px-8 py-4 flex items-center justify-between sticky top-0 z-30">
          
          {/* Breadcrumb / Title */}
          <div className="flex items-center gap-3">
            <span className="font-heading text-xs font-bold uppercase tracking-wider text-slate-400">
              Dashboard /
            </span>
            <span className="font-heading font-black text-sm uppercase tracking-tight text-slate-950">
              {activeTab}
            </span>
          </div>

          {/* Top Actions: Search, Telemetry, Notifications */}
          <div className="flex items-center gap-4">
            
            {/* Realtime Status Badge */}
            <div className="hidden lg:inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-bold">
              <Activity size={13} className="animate-pulse" />
              <span>Vision Engine: Online (208ms)</span>
            </div>

            {/* Quick Search */}
            <div className="relative hidden sm:block w-48 lg:w-64">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                <Search size={14} />
              </div>
              <input
                type="text"
                placeholder="Global search..."
                className="w-full pl-8 pr-3 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs placeholder-slate-400 focus:bg-white focus:outline-none focus:border-[#0066ff] transition-all"
              />
            </div>

            {/* Notifications */}
            <button className="p-2 rounded-xl text-slate-500 hover:bg-slate-100 relative transition-colors cursor-pointer">
              <Bell size={18} />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-[#0066ff]" />
            </button>
          </div>

        </header>

        {/* Section Body */}
        <div className="p-4 sm:p-6 lg:p-8 flex-1 max-w-7xl w-full mx-auto">
          {activeTab === 'overview' && <Overview onNavigateTab={setActiveTab} />}
          {activeTab === 'analytics' && <Analytics />}
          {activeTab === 'classifications' && <Classifications />}
          {activeTab === 'users' && <Users />}
        </div>

      </main>

    </div>
  );
};

export default Dashboard;
