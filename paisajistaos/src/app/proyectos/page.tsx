'use client';

import React, { useState } from 'react';
import { useApp } from '@/lib/context';
import { Card, CardContent } from '@/components/ui/Card';
import Badge from '@/components/ui/Badge';
import ProgressBar from '@/components/ui/ProgressBar';
import Modal from '@/components/ui/Modal';
import Link from 'next/link';
import { Plus, MapPin, Calendar, Filter } from 'lucide-react';
import { projectStatusColor, projectStatusLabel, formatDate, formatCOP, genId } from '@/lib/utils';
import { ProjectStatus } from '@/types';

export default function ProjectsPage() {
  const { state, addProject } = useApp();
  const { projects, tasks, missingItems } = state;
  const [filter, setFilter] = useState<ProjectStatus | 'todos'>('todos');
  const [showNew, setShowNew] = useState(false);

  const filtered = filter === 'todos' ? projects : projects.filter(p => p.status === filter);

  const getProgress = (pid: string) => {
    const pt = tasks.filter(t => t.projectId === pid);
    if (pt.length === 0) return 0;
    return Math.round((pt.filter(t => t.status === 'hecho').length / pt.length) * 100);
  };

  const handleCreate = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    addProject({
      id: genId(),
      name: fd.get('name') as string,
      clientName: fd.get('clientName') as string,
      clientPhone: fd.get('clientPhone') as string,
      locationText: fd.get('location') as string,
      status: 'activo',
      startDate: fd.get('startDate') as string,
      endDate: fd.get('endDate') as string,
      estimatedCost: Number(fd.get('cost')) || undefined,
      description: fd.get('description') as string,
      createdAt: new Date().toISOString().slice(0, 10),
    });
    setShowNew(false);
  };

  const filters: { value: ProjectStatus | 'todos'; label: string }[] = [
    { value: 'todos', label: 'Todos' },
    { value: 'activo', label: 'Activos' },
    { value: 'en_pausa', label: 'En Pausa' },
    { value: 'terminado', label: 'Terminados' },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Proyectos</h1>
          <p className="text-gray-500 text-sm mt-1">{projects.length} proyectos en total</p>
        </div>
        <button
          onClick={() => setShowNew(true)}
          className="flex items-center gap-2 bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 transition-colors text-sm font-medium"
        >
          <Plus className="w-4 h-4" /> Nuevo proyecto
        </button>
      </div>

      {/* Filters */}
      <div className="flex items-center gap-2 flex-wrap">
        <Filter className="w-4 h-4 text-gray-400" />
        {filters.map(f => (
          <button
            key={f.value}
            onClick={() => setFilter(f.value)}
            className={`px-3 py-1.5 rounded-full text-sm font-medium transition-colors ${
              filter === f.value
                ? 'bg-primary-600 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {f.label}
          </button>
        ))}
      </div>

      {/* Project Grid */}
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {filtered.map(p => {
          const progress = getProgress(p.id);
          const missingCount = missingItems.filter(m => m.projectId === p.id && m.status === 'pendiente').length;
          const taskCount = tasks.filter(t => t.projectId === p.id).length;
          return (
            <Link key={p.id} href={`/proyectos/${p.id}`}>
              <Card className="h-full hover:border-primary-300 hover:shadow-md transition-all">
                <CardContent className="space-y-3">
                  <div className="flex items-start justify-between">
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-gray-900 truncate">{p.name}</p>
                      <p className="text-sm text-gray-500">{p.clientName}</p>
                    </div>
                    <Badge className={projectStatusColor(p.status)}>{projectStatusLabel(p.status)}</Badge>
                  </div>
                  <div className="flex items-center gap-1 text-xs text-gray-500">
                    <MapPin className="w-3 h-3" />
                    <span className="truncate">{p.locationText}</span>
                  </div>
                  <div>
                    <div className="flex items-center justify-between text-sm mb-1">
                      <span className="text-gray-600">Progreso</span>
                      <span className="font-semibold text-primary-600">{progress}%</span>
                    </div>
                    <ProgressBar value={progress} />
                  </div>
                  <div className="flex items-center justify-between text-xs text-gray-500">
                    <span className="flex items-center gap-1">
                      <Calendar className="w-3 h-3" />
                      {formatDate(p.startDate)} - {formatDate(p.endDate)}
                    </span>
                  </div>
                  <div className="flex gap-2 text-xs">
                    <span className="bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full">{taskCount} tareas</span>
                    {missingCount > 0 && (
                      <span className="bg-yellow-100 text-yellow-700 px-2 py-0.5 rounded-full">{missingCount} faltantes</span>
                    )}
                    {p.estimatedCost && (
                      <span className="bg-blue-50 text-blue-600 px-2 py-0.5 rounded-full">{formatCOP(p.estimatedCost)}</span>
                    )}
                  </div>
                </CardContent>
              </Card>
            </Link>
          );
        })}
      </div>

      {/* New Project Modal */}
      <Modal open={showNew} onClose={() => setShowNew(false)} title="Nuevo Proyecto">
        <form onSubmit={handleCreate} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Nombre del proyecto</label>
            <input name="name" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" placeholder="Ej: Jardín Residencia Norte" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Cliente</label>
              <input name="clientName" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" placeholder="Nombre del cliente" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Teléfono</label>
              <input name="clientPhone" className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" placeholder="+57 300 ..." />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Ubicación</label>
            <input name="location" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" placeholder="Dirección o referencia" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Fecha inicio</label>
              <input name="startDate" type="date" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Fecha entrega</label>
              <input name="endDate" type="date" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Costo estimado (COP)</label>
            <input name="cost" type="number" className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" placeholder="0" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Descripción</label>
            <textarea name="description" rows={2} className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" placeholder="Detalles del proyecto..." />
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <button type="button" onClick={() => setShowNew(false)} className="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg">Cancelar</button>
            <button type="submit" className="px-4 py-2 text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700 font-medium">Crear proyecto</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
