'use client';

import React from 'react';
import { useApp } from '@/lib/context';
import { Card, CardContent } from '@/components/ui/Card';
import Badge from '@/components/ui/Badge';
import ProgressBar from '@/components/ui/ProgressBar';
import Link from 'next/link';
import {
  FolderKanban, AlertTriangle, PackageSearch, Users,
  ArrowRight, Clock, MapPin
} from 'lucide-react';
import { projectStatusColor, projectStatusLabel, priorityColor, formatDate, isOverdue } from '@/lib/utils';

export default function DashboardPage() {
  const { state } = useApp();
  const { projects, tasks, missingItems, projectStaff, users } = state;

  const activeProjects = projects.filter(p => p.status === 'activo');
  const overdueTasks = tasks.filter(t => t.status !== 'hecho' && isOverdue(t.dueDate));
  const urgentMissing = missingItems.filter(m => m.priority === 'alta' && m.status === 'pendiente');
  const activeStaffToday = projectStaff.filter(ps => ps.checkedIn);

  const projectsAtRisk = activeProjects.filter(p => {
    const pTasks = tasks.filter(t => t.projectId === p.id);
    const hasOverdue = pTasks.some(t => t.status !== 'hecho' && isOverdue(t.dueDate));
    const hasUrgentMissing = missingItems.some(m => m.projectId === p.id && m.priority === 'alta' && m.status === 'pendiente');
    return hasOverdue || hasUrgentMissing;
  });

  const getProjectProgress = (projectId: string) => {
    const pTasks = tasks.filter(t => t.projectId === projectId);
    if (pTasks.length === 0) return 0;
    return Math.round((pTasks.filter(t => t.status === 'hecho').length / pTasks.length) * 100);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 text-sm mt-1">Resumen operativo del día</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardContent className="flex items-center gap-3">
            <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
              <FolderKanban className="w-5 h-5 text-primary-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{activeProjects.length}</p>
              <p className="text-xs text-gray-500">Proyectos activos</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3">
            <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
              <AlertTriangle className="w-5 h-5 text-red-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{overdueTasks.length}</p>
              <p className="text-xs text-gray-500">Tareas vencidas</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3">
            <div className="w-10 h-10 bg-yellow-100 rounded-lg flex items-center justify-center">
              <PackageSearch className="w-5 h-5 text-yellow-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{urgentMissing.length}</p>
              <p className="text-xs text-gray-500">Faltantes urgentes</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3">
            <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
              <Users className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{activeStaffToday.length}</p>
              <p className="text-xs text-gray-500">En obra hoy</p>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid lg:grid-cols-2 gap-6">
        {/* Projects at Risk */}
        <Card>
          <div className="px-4 py-3 border-b border-gray-100 flex items-center justify-between">
            <h3 className="font-semibold text-gray-900 flex items-center gap-2">
              <AlertTriangle className="w-4 h-4 text-red-500" />
              Proyectos en riesgo
            </h3>
            <Link href="/proyectos" className="text-primary-600 text-sm hover:underline flex items-center gap-1">
              Ver todos <ArrowRight className="w-3 h-3" />
            </Link>
          </div>
          <CardContent className="space-y-3">
            {projectsAtRisk.length === 0 ? (
              <p className="text-sm text-gray-500 text-center py-4">No hay proyectos en riesgo</p>
            ) : (
              projectsAtRisk.map(p => {
                const progress = getProjectProgress(p.id);
                const pOverdue = tasks.filter(t => t.projectId === p.id && t.status !== 'hecho' && isOverdue(t.dueDate)).length;
                const pUrgent = missingItems.filter(m => m.projectId === p.id && m.priority === 'alta' && m.status === 'pendiente').length;
                return (
                  <Link key={p.id} href={`/proyectos/${p.id}`} className="block p-3 rounded-lg border border-gray-100 hover:border-gray-200 hover:bg-gray-50 transition-colors">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <p className="font-medium text-gray-900 text-sm">{p.name}</p>
                        <p className="text-xs text-gray-500">{p.clientName}</p>
                      </div>
                      <Badge className={projectStatusColor(p.status)}>{projectStatusLabel(p.status)}</Badge>
                    </div>
                    <ProgressBar value={progress} className="mb-2" />
                    <div className="flex gap-3 text-xs">
                      {pOverdue > 0 && <span className="text-red-600">{pOverdue} tareas vencidas</span>}
                      {pUrgent > 0 && <span className="text-yellow-600">{pUrgent} faltantes urgentes</span>}
                    </div>
                  </Link>
                );
              })
            )}
          </CardContent>
        </Card>

        {/* Who is Where Today */}
        <Card>
          <div className="px-4 py-3 border-b border-gray-100 flex items-center justify-between">
            <h3 className="font-semibold text-gray-900 flex items-center gap-2">
              <MapPin className="w-4 h-4 text-blue-500" />
              Quién está dónde hoy
            </h3>
            <Link href="/empleados" className="text-primary-600 text-sm hover:underline flex items-center gap-1">
              Ver todos <ArrowRight className="w-3 h-3" />
            </Link>
          </div>
          <CardContent className="space-y-3">
            {activeStaffToday.length === 0 ? (
              <p className="text-sm text-gray-500 text-center py-4">Nadie ha registrado check-in hoy</p>
            ) : (
              activeStaffToday.map(ps => {
                const user = users.find(u => u.id === ps.userId);
                const project = projects.find(p => p.id === ps.projectId);
                return (
                  <div key={`${ps.projectId}-${ps.userId}`} className="flex items-center gap-3 p-3 rounded-lg border border-gray-100">
                    <div className="w-8 h-8 bg-primary-200 rounded-full flex items-center justify-center text-primary-700 font-semibold text-xs">
                      {user?.name.split(' ').map(n => n[0]).join('')}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900">{user?.name}</p>
                      <p className="text-xs text-gray-500 truncate">{project?.name}</p>
                    </div>
                    <div className="flex items-center gap-1 text-xs text-gray-500">
                      <Clock className="w-3 h-3" />
                      {ps.checkInTime}
                    </div>
                  </div>
                );
              })
            )}
          </CardContent>
        </Card>
      </div>

      {/* Active Projects Overview */}
      <Card>
        <div className="px-4 py-3 border-b border-gray-100">
          <h3 className="font-semibold text-gray-900">Proyectos activos</h3>
        </div>
        <CardContent>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {activeProjects.map(p => {
              const progress = getProjectProgress(p.id);
              const missingCount = missingItems.filter(m => m.projectId === p.id && m.status === 'pendiente').length;
              return (
                <Link key={p.id} href={`/proyectos/${p.id}`} className="block p-4 rounded-lg border border-gray-200 hover:border-primary-300 hover:shadow-sm transition-all">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <p className="font-medium text-gray-900">{p.name}</p>
                      <p className="text-xs text-gray-500 mt-0.5">{p.clientName}</p>
                    </div>
                    <span className="text-lg font-bold text-primary-600">{progress}%</span>
                  </div>
                  <ProgressBar value={progress} className="mb-3" />
                  <div className="flex items-center justify-between text-xs text-gray-500">
                    <span>Entrega: {formatDate(p.endDate)}</span>
                    {missingCount > 0 && (
                      <Badge className="bg-yellow-100 text-yellow-700">{missingCount} faltantes</Badge>
                    )}
                  </div>
                </Link>
              );
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
