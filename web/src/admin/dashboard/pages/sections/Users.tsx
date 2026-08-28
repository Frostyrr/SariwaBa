import React, { useState } from 'react';
import {
  Users as UsersIcon,
  Search,
  Shield,
  CheckCircle2,
  Clock,
  MoreVertical,
  UserPlus,
  UserCheck,
  Building2,
  ShoppingBag,
} from 'lucide-react';

interface UserItem {
  id: string;
  name: string;
  email: string;
  provider: 'google' | 'github';
  role: 'Administrator' | 'Quality Inspector' | 'Market Vendor' | 'Consumer';
  scansCount: number;
  joinedDate: string;
  lastActive: string;
  status: 'Active' | 'Verified' | 'Pending';
}

export const Users: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState<string>('all');

  const mockUsers: UserItem[] = [
    {
      id: 'USR-101',
      name: 'Dr. Alejandro Gomez',
      email: 'a.gomez@fisheries.gov.ph',
      provider: 'google',
      role: 'Administrator',
      scansCount: 412,
      joinedDate: 'Jan 12, 2026',
      lastActive: 'Just now',
      status: 'Verified',
    },
    {
      id: 'USR-102',
      name: 'Maria Dela Cruz',
      email: 'maria.dc@navotasfish.com',
      provider: 'google',
      role: 'Quality Inspector',
      scansCount: 894,
      joinedDate: 'Feb 03, 2026',
      lastActive: '12 mins ago',
      status: 'Verified',
    },
    {
      id: 'USR-103',
      name: 'Ramon Bautista',
      email: 'ramon.bautista@github.com',
      provider: 'github',
      role: 'Market Vendor',
      scansCount: 245,
      joinedDate: 'Mar 15, 2026',
      lastActive: '1 hour ago',
      status: 'Active',
    },
    {
      id: 'USR-104',
      name: 'Kristine Reyes',
      email: 'kristine.reyes@gmail.com',
      provider: 'google',
      role: 'Quality Inspector',
      scansCount: 620,
      joinedDate: 'Apr 02, 2026',
      lastActive: '3 hours ago',
      status: 'Verified',
    },
    {
      id: 'USR-105',
      name: 'Eduardo Tan',
      email: 'ed.tan@pasaymarket.ph',
      provider: 'google',
      role: 'Market Vendor',
      scansCount: 188,
      joinedDate: 'May 19, 2026',
      lastActive: 'Yesterday',
      status: 'Active',
    },
    {
      id: 'USR-106',
      name: 'Sarah Jane Lim',
      email: 'sjlim.dev@github.com',
      provider: 'github',
      role: 'Consumer',
      scansCount: 34,
      joinedDate: 'Jun 08, 2026',
      lastActive: '2 days ago',
      status: 'Active',
    },
  ];

  const filteredUsers = mockUsers.filter((user) => {
    const matchesSearch =
      user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.role.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesRole = roleFilter === 'all' || user.role === roleFilter;

    return matchesSearch && matchesRole;
  });

  const getRoleBadge = (role: UserItem['role']) => {
    switch (role) {
      case 'Administrator':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold uppercase tracking-wider bg-purple-50 text-purple-700 border border-purple-200">
            <Shield size={12} className="text-purple-600" />
            Admin
          </span>
        );
      case 'Quality Inspector':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold uppercase tracking-wider bg-blue-50 text-blue-700 border border-blue-200">
            <UserCheck size={12} className="text-[#0066ff]" />
            Inspector
          </span>
        );
      case 'Market Vendor':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold uppercase tracking-wider bg-emerald-50 text-emerald-700 border border-emerald-200">
            <Building2 size={12} className="text-emerald-600" />
            Vendor
          </span>
        );
      case 'Consumer':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-bold uppercase tracking-wider bg-slate-100 text-slate-700 border border-slate-200">
            <ShoppingBag size={12} className="text-slate-500" />
            Consumer
          </span>
        );
    }
  };

  return (
    <div className="space-y-8">
      {/* Header Bar */}
      <div className="bg-white rounded-3xl border border-slate-200 p-6 sm:p-8 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 border border-blue-200 text-[#0066ff] text-xs font-bold uppercase tracking-wider mb-2">
            <UsersIcon size={13} />
            <span>Identity & Access</span>
          </div>
          <h1 className="font-heading font-black text-2xl sm:text-3xl text-slate-950 uppercase tracking-tight">
            User Directory
          </h1>
          <p className="font-sans text-xs sm:text-sm text-slate-500 mt-1">
            Manage authenticated inspectors, market vendors, and quality control operators.
          </p>
        </div>

        <button className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-2xl bg-[#0066ff] hover:bg-blue-600 text-white font-heading text-xs font-bold uppercase tracking-wider transition-colors cursor-pointer shadow-xs">
          <UserPlus size={14} />
          <span>Invite Inspector</span>
        </button>
      </div>

      {/* User Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div className="bg-white rounded-3xl border border-slate-200 p-5 shadow-xs">
          <p className="font-heading text-xs font-bold uppercase tracking-wider text-slate-400 mb-1">
            Registered Users
          </p>
          <p className="font-heading font-black text-2xl text-slate-950">1,280</p>
          <p className="text-xs text-emerald-600 font-semibold mt-1">+18 this week</p>
        </div>

        <div className="bg-white rounded-3xl border border-slate-200 p-5 shadow-xs">
          <p className="font-heading text-xs font-bold uppercase tracking-wider text-slate-400 mb-1">
            Active Inspectors
          </p>
          <p className="font-heading font-black text-2xl text-[#0066ff]">24</p>
          <p className="text-xs text-slate-500 mt-1">Verified fisheries staff</p>
        </div>

        <div className="bg-white rounded-3xl border border-slate-200 p-5 shadow-xs">
          <p className="font-heading text-xs font-bold uppercase tracking-wider text-slate-400 mb-1">
            Market Vendors
          </p>
          <p className="font-heading font-black text-2xl text-slate-950">86</p>
          <p className="text-xs text-slate-500 mt-1">Commercial merchants</p>
        </div>

        <div className="bg-white rounded-3xl border border-slate-200 p-5 shadow-xs">
          <p className="font-heading text-xs font-bold uppercase tracking-wider text-slate-400 mb-1">
            Active Sessions Today
          </p>
          <p className="font-heading font-black text-2xl text-emerald-600">348</p>
          <p className="text-xs text-slate-500 mt-1">Real-time connections</p>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white rounded-3xl border border-slate-200 p-5 shadow-xs flex flex-col sm:flex-row items-center justify-between gap-4">
        {/* Search */}
        <div className="relative w-full sm:w-80">
          <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
            <Search size={16} />
          </div>
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search by name, email, or role..."
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl font-sans text-xs sm:text-sm placeholder-slate-400 focus:bg-white focus:outline-none focus:border-[#0066ff] transition-all"
          />
        </div>

        {/* Role Filters */}
        <div className="flex items-center gap-2 w-full sm:w-auto overflow-x-auto pb-1 sm:pb-0">
          {[
            { label: 'All Roles', value: 'all' },
            { label: 'Inspectors', value: 'Quality Inspector' },
            { label: 'Vendors', value: 'Market Vendor' },
            { label: 'Consumers', value: 'Consumer' },
            { label: 'Admins', value: 'Administrator' },
          ].map((item) => (
            <button
              key={item.value}
              onClick={() => setRoleFilter(item.value)}
              className={`px-3.5 py-1.5 rounded-xl text-xs font-bold uppercase tracking-wider transition-all cursor-pointer whitespace-nowrap ${
                roleFilter === item.value
                  ? 'bg-slate-950 text-white shadow-xs'
                  : 'bg-slate-100 hover:bg-slate-200 text-slate-600'
              }`}
            >
              {item.label}
            </button>
          ))}
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-white rounded-3xl border border-slate-200 overflow-hidden shadow-xs">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-slate-100 bg-slate-50/60 text-[11px] font-heading font-bold uppercase tracking-wider text-slate-400">
                <th className="py-3.5 pl-6">User / Account</th>
                <th className="py-3.5">Assigned Role</th>
                <th className="py-3.5">Total Scans</th>
                <th className="py-3.5">Status</th>
                <th className="py-3.5">Last Active</th>
                <th className="py-3.5 text-right pr-6">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-sans text-xs">
              {filteredUsers.map((user) => (
                <tr key={user.id} className="hover:bg-slate-50/80 transition-colors">
                  <td className="py-4 pl-6">
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-xl bg-blue-50 border border-blue-100 text-[#0066ff] flex items-center justify-center font-heading font-black text-sm">
                        {user.name.charAt(0)}
                      </div>
                      <div>
                        <span className="font-heading font-bold text-slate-900 block">{user.name}</span>
                        <span className="text-slate-400 font-mono text-[11px] flex items-center gap-1.5">
                          {user.provider === 'google' ? 'Google' : 'GitHub'} • {user.email}
                        </span>
                      </div>
                    </div>
                  </td>
                  <td className="py-4">{getRoleBadge(user.role)}</td>
                  <td className="py-4 font-mono font-bold text-slate-700">{user.scansCount} scans</td>
                  <td className="py-4">
                    <span className="inline-flex items-center gap-1 text-emerald-600 font-semibold">
                      <CheckCircle2 size={13} />
                      {user.status}
                    </span>
                  </td>
                  <td className="py-4 text-slate-400 flex items-center gap-1.5 pt-6">
                    <Clock size={13} />
                    <span>{user.lastActive}</span>
                  </td>
                  <td className="py-4 text-right pr-6">
                    <button className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-700 cursor-pointer transition-colors">
                      <MoreVertical size={16} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Users;
