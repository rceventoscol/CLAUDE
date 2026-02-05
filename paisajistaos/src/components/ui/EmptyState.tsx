import React from 'react';
import { Inbox } from 'lucide-react';

export default function EmptyState({ message, action }: { message: string; action?: React.ReactNode }) {
  return (
    <div className="flex flex-col items-center justify-center py-12 text-center">
      <Inbox className="w-12 h-12 text-gray-300 mb-3" />
      <p className="text-gray-500 mb-4">{message}</p>
      {action}
    </div>
  );
}
