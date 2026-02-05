'use client';

import React, { useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useApp } from '@/lib/context';
import { Card, CardContent } from '@/components/ui/Card';
import Badge from '@/components/ui/Badge';
import ProgressBar from '@/components/ui/ProgressBar';
import Modal from '@/components/ui/Modal';
import EmptyState from '@/components/ui/EmptyState';
import {
  ArrowLeft, MapPin, Calendar, DollarSign, Plus,
  CheckCircle2, Circle, Clock, AlertTriangle, Camera,
  GripVertical, User as UserIcon, Package, Send
} from 'lucide-react';
import {
  projectStatusColor, projectStatusLabel, formatDate, formatDateTime,
  formatCOP, priorityColor, taskStatusColor, taskStatusLabel,
  missingStatusColor, missingStatusLabel, categoryLabel, categoryIcon,
  tagColor, genId, isOverdue
} from '@/lib/utils';
import { TaskStatus, Priority, MissingItemCategory, MissingItemStatus, MediaTag } from '@/types';
import Link from 'next/link';

type Tab = 'resumen' | 'tareas' | 'cuadrillas' | 'faltantes' | 'bitacora';

export default function ProjectDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { state, updateTasks, addTask, updateMissingItems, addMissingItem, addLogMedia, updateProjectStaff, addPurchaseOrder } = useApp();
  const [activeTab, setActiveTab] = useState<Tab>('resumen');
  const [showNewTask, setShowNewTask] = useState(false);
  const [showNewMissing, setShowNewMissing] = useState(false);
  const [showNewMedia, setShowNewMedia] = useState(false);

  const project = state.projects.find(p => p.id === params.id);
  if (!project) return <div className="p-8 text-center text-gray-500">Proyecto no encontrado</div>;

  const projectTasks = state.tasks.filter(t => t.projectId === project.id);
  const projectMissing = state.missingItems.filter(m => m.projectId === project.id);
  const projectStaff = state.projectStaff.filter(ps => ps.projectId === project.id);
  const projectMedia = state.logMedia.filter(lm => lm.projectId === project.id).sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  const projectPOs = state.purchaseOrders.filter(po => po.projectId === project.id);

  const totalTasks = projectTasks.length;
  const doneTasks = projectTasks.filter(t => t.status === 'hecho').length;
  const progress = totalTasks > 0 ? Math.round((doneTasks / totalTasks) * 100) : 0;

  const tabs: { key: Tab; label: string; count?: number }[] = [
    { key: 'resumen', label: 'Resumen' },
    { key: 'tareas', label: 'Tareas', count: totalTasks },
    { key: 'cuadrillas', label: 'Cuadrillas', count: projectStaff.length },
    { key: 'faltantes', label: 'Faltantes', count: projectMissing.filter(m => m.status === 'pendiente').length },
    { key: 'bitacora', label: 'Bitácora', count: projectMedia.length },
  ];

  const moveTask = (taskId: string, newStatus: TaskStatus) => {
    updateTasks(tasks => tasks.map(t => t.id === taskId ? { ...t, status: newStatus } : t));
  };

  const handleNewTask = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    addTask({
      id: genId(),
      projectId: project.id,
      title: fd.get('title') as string,
      description: fd.get('description') as string,
      status: 'pendiente',
      priority: fd.get('priority') as Priority,
      dueDate: fd.get('dueDate') as string,
      assignedUserId: fd.get('assignedUserId') as string || undefined,
      createdAt: new Date().toISOString().slice(0, 10),
    });
    setShowNewTask(false);
  };

  const handleNewMissing = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    addMissingItem({
      id: genId(),
      projectId: project.id,
      category: fd.get('category') as MissingItemCategory,
      name: fd.get('name') as string,
      qty: Number(fd.get('qty')),
      priority: fd.get('priority') as Priority,
      neededBy: fd.get('neededBy') as string,
      status: 'pendiente',
      supplier: fd.get('supplier') as string || undefined,
    });
    setShowNewMissing(false);
  };

  const handleNewMedia = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const tags = (fd.get('tags') as string).split(',').map(t => t.trim()).filter(Boolean) as MediaTag[];
    addLogMedia({
      id: genId(),
      projectId: project.id,
      url: '/placeholder-new.jpg',
      caption: fd.get('caption') as string,
      tags,
      createdBy: 'u1',
      createdAt: new Date().toISOString(),
    });
    setShowNewMedia(false);
  };

  const convertToOrder = () => {
    const pending = projectMissing.filter(m => m.status === 'pendiente');
    if (pending.length === 0) return;
    const poId = genId();
    const items = pending.map(m => ({
      id: genId(),
      purchaseOrderId: poId,
      name: m.name,
      qty: m.qty,
      unitCostEst: 0,
    }));
    addPurchaseOrder(
      {
        id: poId,
        projectId: project.id,
        supplierName: pending[0].supplier || 'Por definir',
        status: 'borrador',
        totalEstimated: 0,
        createdAt: new Date().toISOString().slice(0, 10),
      },
      items
    );
  };

  const shareWhatsApp = () => {
    const text = `*Avance: ${project.name}*\n\nCliente: ${project.clientName}\nProgreso: ${progress}%\nTareas completadas: ${doneTasks}/${totalTasks}\nFaltantes pendientes: ${projectMissing.filter(m => m.status === 'pendiente').length}\n\n_Generado por PaisajistaOS_`;
    window.open(`https://wa.me/?text=${encodeURIComponent(text)}`, '_blank');
  };

  const kanbanColumns: { status: TaskStatus; label: string; color: string }[] = [
    { status: 'pendiente', label: 'Pendiente', color: 'border-t-slate-400' },
    { status: 'en_proceso', label: 'En Proceso', color: 'border-t-blue-400' },
    { status: 'hecho', label: 'Hecho', color: 'border-t-green-400' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-start gap-3">
        <button onClick={() => router.back()} className="p-2 hover:bg-gray-100 rounded-lg mt-0.5">
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div className="flex-1">
          <div className="flex items-center gap-3 flex-wrap">
            <h1 className="text-xl font-bold text-gray-900">{project.name}</h1>
            <Badge className={projectStatusColor(project.status)}>{projectStatusLabel(project.status)}</Badge>
          </div>
          <div className="flex items-center gap-4 mt-1 text-sm text-gray-500 flex-wrap">
            <span>{project.clientName}</span>
            <span className="flex items-center gap-1"><MapPin className="w-3 h-3" />{project.locationText}</span>
            <span className="flex items-center gap-1"><Calendar className="w-3 h-3" />{formatDate(project.startDate)} - {formatDate(project.endDate)}</span>
            {project.estimatedCost && <span className="flex items-center gap-1"><DollarSign className="w-3 h-3" />{formatCOP(project.estimatedCost)}</span>}
          </div>
        </div>
        <button onClick={shareWhatsApp} className="flex items-center gap-2 bg-green-600 text-white px-3 py-2 rounded-lg hover:bg-green-700 text-sm font-medium">
          <Send className="w-4 h-4" /> WhatsApp
        </button>
      </div>

      {/* Progress Bar */}
      <Card>
        <CardContent>
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-gray-700">Progreso general</span>
            <span className="text-lg font-bold text-primary-600">{progress}%</span>
          </div>
          <ProgressBar value={progress} />
          <p className="text-xs text-gray-500 mt-2">{doneTasks} de {totalTasks} tareas completadas</p>
        </CardContent>
      </Card>

      {/* Tabs */}
      <div className="flex gap-1 overflow-x-auto border-b border-gray-200 -mb-px">
        {tabs.map(tab => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            className={`px-4 py-2.5 text-sm font-medium whitespace-nowrap border-b-2 transition-colors ${
              activeTab === tab.key
                ? 'border-primary-600 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700'
            }`}
          >
            {tab.label}
            {tab.count !== undefined && (
              <span className="ml-1.5 text-xs bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded-full">{tab.count}</span>
            )}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      {activeTab === 'resumen' && (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <Card>
            <CardContent>
              <h4 className="text-sm font-medium text-gray-500 mb-2">Tareas</h4>
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Pendientes</span>
                  <span className="font-medium">{projectTasks.filter(t => t.status === 'pendiente').length}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>En proceso</span>
                  <span className="font-medium">{projectTasks.filter(t => t.status === 'en_proceso').length}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>Completadas</span>
                  <span className="font-medium text-green-600">{doneTasks}</span>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent>
              <h4 className="text-sm font-medium text-gray-500 mb-2">Faltantes</h4>
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Pendientes</span>
                  <span className="font-medium text-red-600">{projectMissing.filter(m => m.status === 'pendiente').length}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>En orden/comprado</span>
                  <span className="font-medium">{projectMissing.filter(m => ['en_orden', 'comprado'].includes(m.status)).length}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>Entregado/Instalado</span>
                  <span className="font-medium text-green-600">{projectMissing.filter(m => ['entregado', 'instalado'].includes(m.status)).length}</span>
                </div>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardContent>
              <h4 className="text-sm font-medium text-gray-500 mb-2">Órdenes de compra</h4>
              <p className="text-2xl font-bold text-gray-900">{projectPOs.length}</p>
              <div className="mt-2 space-y-1">
                {projectPOs.map(po => (
                  <div key={po.id} className="flex items-center justify-between text-xs">
                    <span className="text-gray-600">{po.supplierName}</span>
                    <Badge className={`text-xs ${po.status === 'entregado' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'}`}>{po.status}</Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
          {project.description && (
            <Card className="sm:col-span-2 lg:col-span-3">
              <CardContent>
                <h4 className="text-sm font-medium text-gray-500 mb-1">Descripción</h4>
                <p className="text-sm text-gray-700">{project.description}</p>
              </CardContent>
            </Card>
          )}
        </div>
      )}

      {activeTab === 'tareas' && (
        <div>
          <div className="flex justify-end mb-4">
            <button onClick={() => setShowNewTask(true)} className="flex items-center gap-2 bg-primary-600 text-white px-3 py-2 rounded-lg hover:bg-primary-700 text-sm font-medium">
              <Plus className="w-4 h-4" /> Nueva tarea
            </button>
          </div>
          <div className="grid md:grid-cols-3 gap-4">
            {kanbanColumns.map(col => (
              <div key={col.status} className={`bg-gray-50 rounded-xl p-3 border-t-4 ${col.color} kanban-column`}>
                <div className="flex items-center justify-between mb-3">
                  <h4 className="font-semibold text-sm text-gray-700">{col.label}</h4>
                  <span className="text-xs bg-white text-gray-500 px-2 py-0.5 rounded-full border">
                    {projectTasks.filter(t => t.status === col.status).length}
                  </span>
                </div>
                <div className="space-y-2">
                  {projectTasks.filter(t => t.status === col.status).map(task => {
                    const assignee = state.users.find(u => u.id === task.assignedUserId);
                    return (
                      <div key={task.id} className="bg-white rounded-lg p-3 shadow-sm border border-gray-100">
                        <div className="flex items-start gap-2">
                          <GripVertical className="w-4 h-4 text-gray-300 mt-0.5 flex-shrink-0" />
                          <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium text-gray-900">{task.title}</p>
                            <div className="flex items-center gap-2 mt-2 flex-wrap">
                              <Badge className={priorityColor(task.priority)}>{task.priority}</Badge>
                              {isOverdue(task.dueDate) && task.status !== 'hecho' && (
                                <Badge className="bg-red-100 text-red-700">Vencida</Badge>
                              )}
                              <span className="text-xs text-gray-400">{formatDate(task.dueDate)}</span>
                            </div>
                            {assignee && (
                              <div className="flex items-center gap-1 mt-2 text-xs text-gray-500">
                                <UserIcon className="w-3 h-3" />{assignee.name}
                              </div>
                            )}
                            <div className="flex gap-1 mt-2">
                              {col.status !== 'pendiente' && (
                                <button onClick={() => moveTask(task.id, col.status === 'hecho' ? 'en_proceso' : 'pendiente')} className="text-xs text-gray-500 hover:text-gray-700 px-2 py-1 bg-gray-50 rounded">
                                  ← Atrás
                                </button>
                              )}
                              {col.status !== 'hecho' && (
                                <button onClick={() => moveTask(task.id, col.status === 'pendiente' ? 'en_proceso' : 'hecho')} className="text-xs text-primary-600 hover:text-primary-700 px-2 py-1 bg-primary-50 rounded">
                                  Avanzar →
                                </button>
                              )}
                            </div>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'cuadrillas' && (
        <div className="space-y-4">
          <Card>
            <div className="px-4 py-3 border-b border-gray-100">
              <h4 className="font-semibold text-gray-900">Personal asignado</h4>
            </div>
            <CardContent>
              {projectStaff.length === 0 ? (
                <EmptyState message="No hay personal asignado a este proyecto" />
              ) : (
                <div className="space-y-3">
                  {projectStaff.map(ps => {
                    const user = state.users.find(u => u.id === ps.userId);
                    if (!user) return null;
                    return (
                      <div key={ps.userId} className="flex items-center justify-between p-3 rounded-lg border border-gray-100">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 bg-primary-200 rounded-full flex items-center justify-center text-primary-700 font-semibold text-sm">
                            {user.name.split(' ').map(n => n[0]).join('')}
                          </div>
                          <div>
                            <p className="text-sm font-medium text-gray-900">{user.name}</p>
                            <p className="text-xs text-gray-500">{user.role} · {user.phone}</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          {ps.checkedIn ? (
                            <Badge className="bg-green-100 text-green-700">
                              <CheckCircle2 className="w-3 h-3 mr-1" /> En obra {ps.checkInTime}
                            </Badge>
                          ) : (
                            <Badge className="bg-gray-100 text-gray-500">
                              <Circle className="w-3 h-3 mr-1" /> Sin check-in
                            </Badge>
                          )}
                          <button
                            onClick={() => {
                              updateProjectStaff(staff =>
                                staff.map(s =>
                                  s.projectId === project.id && s.userId === ps.userId
                                    ? { ...s, checkedIn: !s.checkedIn, checkInTime: !s.checkedIn ? new Date().toTimeString().slice(0, 5) : undefined }
                                    : s
                                )
                              );
                            }}
                            className="text-xs text-primary-600 hover:underline"
                          >
                            {ps.checkedIn ? 'Check-out' : 'Check-in'}
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      )}

      {activeTab === 'faltantes' && (
        <div>
          <div className="flex justify-between items-center mb-4 flex-wrap gap-2">
            <div className="flex gap-2">
              {projectMissing.filter(m => m.status === 'pendiente').length > 0 && (
                <button onClick={convertToOrder} className="flex items-center gap-2 bg-accent-500 text-white px-3 py-2 rounded-lg hover:bg-accent-600 text-sm font-medium">
                  <Package className="w-4 h-4" /> Convertir faltantes en orden
                </button>
              )}
            </div>
            <button onClick={() => setShowNewMissing(true)} className="flex items-center gap-2 bg-primary-600 text-white px-3 py-2 rounded-lg hover:bg-primary-700 text-sm font-medium">
              <Plus className="w-4 h-4" /> Agregar faltante
            </button>
          </div>
          {projectMissing.length === 0 ? (
            <EmptyState message="No hay faltantes registrados" action={
              <button onClick={() => setShowNewMissing(true)} className="text-primary-600 hover:underline text-sm">Agregar el primero</button>
            } />
          ) : (
            <div className="space-y-2">
              {projectMissing.map(item => (
                <Card key={item.id}>
                  <CardContent className="flex items-center justify-between flex-wrap gap-2">
                    <div className="flex items-center gap-3">
                      <span className="text-lg">{categoryIcon(item.category)}</span>
                      <div>
                        <p className="text-sm font-medium text-gray-900">{item.name}</p>
                        <p className="text-xs text-gray-500">
                          {categoryLabel(item.category)} · Cant: {item.qty} · Fecha: {formatDate(item.neededBy)}
                          {item.supplier && ` · ${item.supplier}`}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Badge className={priorityColor(item.priority)}>{item.priority}</Badge>
                      <Badge className={missingStatusColor(item.status)}>{missingStatusLabel(item.status)}</Badge>
                      {item.status === 'pendiente' && (
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
                      )}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>
      )}

      {activeTab === 'bitacora' && (
        <div>
          <div className="flex justify-end mb-4">
            <button onClick={() => setShowNewMedia(true)} className="flex items-center gap-2 bg-primary-600 text-white px-3 py-2 rounded-lg hover:bg-primary-700 text-sm font-medium">
              <Camera className="w-4 h-4" /> Subir evidencia
            </button>
          </div>
          {projectMedia.length === 0 ? (
            <EmptyState message="No hay evidencia visual registrada" action={
              <button onClick={() => setShowNewMedia(true)} className="text-primary-600 hover:underline text-sm">Subir la primera foto</button>
            } />
          ) : (
            <div className="space-y-4">
              {projectMedia.map(media => {
                const author = state.users.find(u => u.id === media.createdBy);
                return (
                  <Card key={media.id}>
                    <CardContent>
                      <div className="flex gap-4">
                        <div className="w-24 h-24 bg-gradient-to-br from-primary-200 to-primary-400 rounded-lg flex items-center justify-center text-white flex-shrink-0">
                          <Camera className="w-8 h-8" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium text-gray-900">{media.caption}</p>
                          <div className="flex items-center gap-2 mt-1 text-xs text-gray-500">
                            <span>{formatDateTime(media.createdAt)}</span>
                            {author && <span>· {author.name}</span>}
                          </div>
                          <div className="flex gap-1 mt-2 flex-wrap">
                            {media.tags.map(tag => (
                              <Badge key={tag} className={tagColor(tag)}>{tag}</Badge>
                            ))}
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                );
              })}
            </div>
          )}
        </div>
      )}

      {/* Modals */}
      <Modal open={showNewTask} onClose={() => setShowNewTask(false)} title="Nueva Tarea">
        <form onSubmit={handleNewTask} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Título</label>
            <input name="title" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Descripción</label>
            <textarea name="description" rows={2} className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Prioridad</label>
              <select name="priority" className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none">
                <option value="alta">Alta</option>
                <option value="media" selected>Media</option>
                <option value="baja">Baja</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Fecha límite</label>
              <input name="dueDate" type="date" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none" />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Asignar a</label>
            <select name="assignedUserId" className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none">
              <option value="">Sin asignar</option>
              {state.users.filter(u => u.role !== 'cliente').map(u => (
                <option key={u.id} value={u.id}>{u.name}</option>
              ))}
            </select>
          </div>
          <div className="flex justify-end gap-2">
            <button type="button" onClick={() => setShowNewTask(false)} className="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg">Cancelar</button>
            <button type="submit" className="px-4 py-2 text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700 font-medium">Crear</button>
          </div>
        </form>
      </Modal>

      <Modal open={showNewMissing} onClose={() => setShowNewMissing(false)} title="Nuevo Faltante">
        <form onSubmit={handleNewMissing} className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Categoría</label>
              <select name="category" className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none">
                <option value="planta">Planta</option>
                <option value="insumo">Insumo</option>
                <option value="matera">Matera</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Prioridad</label>
              <select name="priority" className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none">
                <option value="alta">Alta</option>
                <option value="media">Media</option>
                <option value="baja">Baja</option>
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Nombre</label>
            <input name="name" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none" placeholder="Ej: Crotones grandes" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Cantidad</label>
              <input name="qty" type="number" min="1" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Fecha requerida</label>
              <input name="neededBy" type="date" required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none" />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Proveedor (opcional)</label>
            <input name="supplier" className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none" placeholder="Ej: Vivero El Jardín" />
          </div>
          <div className="flex justify-end gap-2">
            <button type="button" onClick={() => setShowNewMissing(false)} className="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg">Cancelar</button>
            <button type="submit" className="px-4 py-2 text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700 font-medium">Agregar</button>
          </div>
        </form>
      </Modal>

      <Modal open={showNewMedia} onClose={() => setShowNewMedia(false)} title="Subir Evidencia">
        <form onSubmit={handleNewMedia} className="space-y-4">
          <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
            <Camera className="w-8 h-8 text-gray-400 mx-auto mb-2" />
            <p className="text-sm text-gray-500">Arrastra una foto o haz clic para seleccionar</p>
            <p className="text-xs text-gray-400 mt-1">(Demo: se usará imagen placeholder)</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Comentario</label>
            <textarea name="caption" rows={2} required className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none" placeholder="Describe lo que muestra la foto..." />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Tags (separados por coma)</label>
            <input name="tags" className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-primary-500 outline-none" placeholder="durante, riego, instalación" defaultValue="durante, general" />
          </div>
          <div className="flex justify-end gap-2">
            <button type="button" onClick={() => setShowNewMedia(false)} className="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg">Cancelar</button>
            <button type="submit" className="px-4 py-2 text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700 font-medium">Subir</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
