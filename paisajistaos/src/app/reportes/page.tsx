'use client';

import React, { useState } from 'react';
import { useApp } from '@/lib/context';
import { Card, CardContent } from '@/components/ui/Card';
import Badge from '@/components/ui/Badge';
import ProgressBar from '@/components/ui/ProgressBar';
import { FileText, Send, Download, CheckCircle2, AlertTriangle, Package } from 'lucide-react';
import { formatDate, formatCOP, missingStatusLabel, projectStatusLabel, projectStatusColor } from '@/lib/utils';

export default function ReportesPage() {
  const { state } = useApp();
  const { projects, tasks, missingItems, logMedia, projectStaff, users } = state;
  const [selectedProject, setSelectedProject] = useState<string>(projects[0]?.id || '');

  const project = projects.find(p => p.id === selectedProject);
  if (!project) return null;

  const projectTasks = tasks.filter(t => t.projectId === project.id);
  const totalTasks = projectTasks.length;
  const doneTasks = projectTasks.filter(t => t.status === 'hecho').length;
  const progress = totalTasks > 0 ? Math.round((doneTasks / totalTasks) * 100) : 0;

  const projectMissing = missingItems.filter(m => m.projectId === project.id);
  const projectMedia = logMedia.filter(m => m.projectId === project.id);
  const projectStaffList = projectStaff.filter(ps => ps.projectId === project.id);

  const generateWhatsAppReport = () => {
    const pendingMissing = projectMissing.filter(m => m.status === 'pendiente');
    const recentPhotos = projectMedia.slice(0, 3);

    let text = `*Reporte Semanal*\n`;
    text += `*${project.name}*\n\n`;
    text += `Cliente: ${project.clientName}\n`;
    text += `Progreso: ${progress}% (${doneTasks}/${totalTasks} tareas)\n\n`;

    text += `*Tareas completadas esta semana:*\n`;
    projectTasks.filter(t => t.status === 'hecho').slice(0, 5).forEach(t => {
      text += `  ✅ ${t.title}\n`;
    });

    text += `\n*En proceso:*\n`;
    projectTasks.filter(t => t.status === 'en_proceso').forEach(t => {
      text += `  🔄 ${t.title}\n`;
    });

    if (pendingMissing.length > 0) {
      text += `\n*Faltantes pendientes (${pendingMissing.length}):*\n`;
      pendingMissing.forEach(m => {
        text += `  ⚠️ ${m.name} x${m.qty}\n`;
      });
    }

    text += `\n*Evidencia reciente:* ${recentPhotos.length} fotos\n`;
    text += `\n---\n_Generado por PaisajistaOS_`;

    window.open(`https://wa.me/${project.clientPhone?.replace(/\D/g, '') || ''}?text=${encodeURIComponent(text)}`, '_blank');
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Reportes</h1>
          <p className="text-gray-500 text-sm mt-1">Genera reportes de avance por proyecto</p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={generateWhatsAppReport}
            className="flex items-center gap-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 text-sm font-medium"
          >
            <Send className="w-4 h-4" /> Enviar por WhatsApp
          </button>
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Seleccionar proyecto</label>
        <select
          className="border rounded-lg px-3 py-2 text-sm w-full max-w-md"
          value={selectedProject}
          onChange={(e) => setSelectedProject(e.target.value)}
        >
          {projects.map(p => (
            <option key={p.id} value={p.id}>{p.name} - {p.clientName}</option>
          ))}
        </select>
      </div>

      {/* Report Preview */}
      <Card>
        <div className="px-6 py-4 border-b border-gray-100 bg-primary-50">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-lg font-bold text-gray-900">{project.name}</h2>
              <p className="text-sm text-gray-600">Reporte semanal - {formatDate(new Date().toISOString().slice(0, 10))}</p>
            </div>
            <Badge className={projectStatusColor(project.status)}>{projectStatusLabel(project.status)}</Badge>
          </div>
        </div>

        <CardContent className="space-y-6">
          {/* Progress */}
          <div>
            <h3 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-primary-500" />
              Progreso general
            </h3>
            <div className="flex items-center gap-4">
              <div className="flex-1">
                <ProgressBar value={progress} />
              </div>
              <span className="text-xl font-bold text-primary-600">{progress}%</span>
            </div>
            <p className="text-sm text-gray-500 mt-1">{doneTasks} de {totalTasks} tareas completadas</p>
          </div>

          {/* Tasks breakdown */}
          <div>
            <h3 className="font-semibold text-gray-900 mb-2">Desglose de tareas</h3>
            <div className="grid grid-cols-3 gap-3">
              <div className="bg-slate-50 p-3 rounded-lg text-center">
                <p className="text-2xl font-bold text-slate-700">{projectTasks.filter(t => t.status === 'pendiente').length}</p>
                <p className="text-xs text-slate-500">Pendientes</p>
              </div>
              <div className="bg-blue-50 p-3 rounded-lg text-center">
                <p className="text-2xl font-bold text-blue-700">{projectTasks.filter(t => t.status === 'en_proceso').length}</p>
                <p className="text-xs text-blue-500">En proceso</p>
              </div>
              <div className="bg-green-50 p-3 rounded-lg text-center">
                <p className="text-2xl font-bold text-green-700">{doneTasks}</p>
                <p className="text-xs text-green-500">Completadas</p>
              </div>
            </div>
          </div>

          {/* Missing items */}
          {projectMissing.length > 0 && (
            <div>
              <h3 className="font-semibold text-gray-900 mb-2 flex items-center gap-2">
                <Package className="w-4 h-4 text-yellow-500" />
                Faltantes ({projectMissing.length})
              </h3>
              <div className="space-y-1">
                {projectMissing.map(m => (
                  <div key={m.id} className="flex items-center justify-between text-sm py-1.5 border-b border-gray-50">
                    <span className="text-gray-700">{m.name} x{m.qty}</span>
                    <Badge className={`text-xs ${m.status === 'pendiente' ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'}`}>
                      {missingStatusLabel(m.status)}
                    </Badge>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Staff */}
          <div>
            <h3 className="font-semibold text-gray-900 mb-2">Equipo asignado</h3>
            <div className="flex gap-2 flex-wrap">
              {projectStaffList.map(ps => {
                const user = users.find(u => u.id === ps.userId);
                return (
                  <div key={ps.userId} className="flex items-center gap-2 bg-gray-50 px-3 py-1.5 rounded-full text-sm">
                    <div className="w-5 h-5 bg-primary-200 rounded-full flex items-center justify-center text-primary-700 text-xs font-semibold">
                      {user?.name.split(' ').map(n => n[0]).join('')}
                    </div>
                    {user?.name}
                  </div>
                );
              })}
            </div>
          </div>

          {/* Recent evidence */}
          <div>
            <h3 className="font-semibold text-gray-900 mb-2">Evidencia reciente ({projectMedia.length} fotos)</h3>
            <div className="grid grid-cols-3 sm:grid-cols-4 gap-2">
              {projectMedia.slice(0, 4).map(media => (
                <div key={media.id} className="aspect-square bg-gradient-to-br from-primary-200 to-primary-400 rounded-lg flex items-center justify-center">
                  <Camera className="w-6 h-6 text-white" />
                </div>
              ))}
            </div>
          </div>

          {/* Cost */}
          {project.estimatedCost && (
            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="font-semibold text-gray-900 mb-1">Presupuesto</h3>
              <p className="text-xl font-bold text-gray-900">{formatCOP(project.estimatedCost)}</p>
              <p className="text-xs text-gray-500">Costo estimado del proyecto</p>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

function Camera({ className }: { className?: string }) {
  return (
    <svg className={className} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z" />
      <circle cx="12" cy="13" r="3" />
    </svg>
  );
}
