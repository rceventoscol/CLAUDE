import React from 'react';

export function Card({ className = '', children, onClick }: { className?: string; children: React.ReactNode; onClick?: () => void }) {
  return (
    <div className={`bg-white rounded-xl border border-gray-200 shadow-sm ${onClick ? 'cursor-pointer hover:shadow-md transition-shadow' : ''} ${className}`} onClick={onClick}>
      {children}
    </div>
  );
}

export function CardHeader({ className = '', children }: { className?: string; children: React.ReactNode }) {
  return <div className={`px-4 py-3 border-b border-gray-100 ${className}`}>{children}</div>;
}

export function CardContent({ className = '', children }: { className?: string; children: React.ReactNode }) {
  return <div className={`px-4 py-3 ${className}`}>{children}</div>;
}
