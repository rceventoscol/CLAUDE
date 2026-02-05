'use client';

import React from 'react';
import { Menu, Bell } from 'lucide-react';

export default function Header({ onMenuClick }: { onMenuClick: () => void }) {
  return (
    <header className="sticky top-0 z-30 bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between lg:px-6">
      <button onClick={onMenuClick} className="lg:hidden p-2 hover:bg-gray-100 rounded-lg">
        <Menu className="w-5 h-5" />
      </button>
      <div className="hidden lg:block">
        <h2 className="text-sm text-gray-500">Bienvenido de vuelta,</h2>
        <p className="font-semibold text-gray-900">Carlos Ramírez</p>
      </div>
      <div className="flex items-center gap-3">
        <button className="relative p-2 hover:bg-gray-100 rounded-lg">
          <Bell className="w-5 h-5 text-gray-600" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full" />
        </button>
      </div>
    </header>
  );
}
