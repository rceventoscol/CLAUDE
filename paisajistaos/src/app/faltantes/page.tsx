'use client';

import React, { useState } from 'react';
import { useApp } from '@/lib/context';
import { Card, CardContent } from '@/components/ui/Card';
import Badge from '@/components/ui/Badge';
import { Filter, AlertTriangle, Package } from 'lucide-react';
import {
  priorityColor, missingStatusColor, missingStatusLabel,
  categoryLabel, categoryIcon, formatDate
} from '@/lib/utils';
import { MissingItemStatus, Priority } from '@/types';

export default function FaltantesPage() {
  const { state, updateMissingItems } = useApp();
  const { missingItems, projects } = state;
  const [filterStatus, setFilterStatus] = useState<MissingItemStatus | 'todos'>('todos');
  const [filterPriority, setFilterPriority] = useState<Priority | 'todos'>('todos');

  let filtered = missingItems;
  if (filterStatus !== 'todos') filtered = filtered.filter(m => m.status === filterStatus);
  if (filterPriority !== 'todos') filtered = filtered.filter(m => m.priority === filterPriority);

  const grouped = filtered.reduce<Record<string, typeof filtered>>((acc, item) => {
    if (!acc[item.projectId]) acc[item.projectId] = [];
    acc[item.projectId].push(item);
    return acc;
  }, {});

  const urgentCount = missingItems.filter(m => m.priority === 'alta' && m.status === 'pendiente').length;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Faltantes</h1>
          <p className="text-gray-500 text-sm mt-1">{missingItems.length} items en total</p>
        </div>
        {urgentCount > 0 && (
          <div className="flex items-center gap-2 bg-red-50 text-red-700 px-3 py-2 rounded-lg text-sm">
            <AlertTriangle className="w-4 h-4" />
            {urgentCount} faltantes urgentes sin orden
          </div>
        )}
      </div>

      <div className="flex items-center gap-2 flex-wrap">
        <Filter className="w-4 h-4 text-gray-400" />
        <span className="text-xs text-gray-500">Estado:</span>
        {(['todos', 'pendiente', 'en_orden', 'comprado', 'entregado', 'instalado'] as const).map(s => (
          <button
            key={s}
            onClick={() => setFilterStatus(s)}
            className={`px-3 py-1 rounded-full text-xs font-medium ${
              filterStatus === s ? 'bg-primary-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {s === 'todos' ? 'Todos' : missingStatusLabel(s)}
          </button>
        ))}
        <span className="text-xs text-gray-500 ml-2">Prioridad:</span>
        {(['todos', 'alta', 'media', 'baja'] as const).map(p => (
          <button
            key={p}
            onClick={() => setFilterPriority(p)}
            className={`px-3 py-1 rounded-full text-xs font-medium ${
              filterPriority === p ? 'bg-primary-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {p === 'todos' ? 'Todas' : p.charAt(0).toUpperCase() + p.slice(1)}
          </button>
        ))}
      </div>

      {Object.entries(grouped).map(([projectId, items]) => {
        const project = projects.find(p => p.id === projectId);
        return (
          <Card key={projectId}>
            <div className="px-4 py-3 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-semibold text-gray-900">{project?.name || 'Proyecto'}</h3>
              <span className="text-xs text-gray-500">{items.length} items</span>
            </div>
            <CardContent className="divide-y divide-gray-50">
              {items.map(item => (
                <div key={item.id} className="flex items-center justify-between py-2 flex-wrap gap-2">
                  <div className="flex items-center gap-3">
                    <span className="text-lg">{categoryIcon(item.category)}</span>
                    <div>
                      <p className="text-sm font-medium text-gray-900">{item.name}</p>
                      <p className="text-xs text-gray-500">
                        {categoryLabel(item.category)} · Cant: {item.qty} · Para: {formatDate(item.neededBy)}
                        {item.supplier && ` · ${item.supplier}`}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <Badge className={priorityColor(item.priority)}>{item.priority}</Badge>
                    <select
                      className="text-xs border rounded px-2 py-1"
                      value={item.status}
                      onChange={(e) => updateMissingItems(items =>
                        items.map(m => m.id === item.id ? { ...m, status: e.target.value as MissingItemStatus } : m)
                      )}
                    >
                      <option value="pendiente">Pendiente</option>
                      <option value="en_orden">En Orden</option>
                      <option value="comprado">Comprado</option>
                      <option value="entregado">Entregado</option>
                      <option value="instalado">Instalado</option>
                    </select>
                  </div>
                </div>
              ))}
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}
