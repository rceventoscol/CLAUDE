import { Priority, ProjectStatus, TaskStatus, MissingItemStatus, PurchaseOrderStatus, MissingItemCategory, MediaTag } from '@/types';

export function formatCOP(amount: number): string {
  return new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount);
}

export function formatDate(dateStr: string): string {
  return new Date(dateStr + 'T12:00:00').toLocaleDateString('es-CO', { day: 'numeric', month: 'short', year: 'numeric' });
}

export function formatDateTime(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('es-CO', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
}

export function priorityColor(p: Priority): string {
  return { alta: 'bg-red-100 text-red-700', media: 'bg-yellow-100 text-yellow-700', baja: 'bg-blue-100 text-blue-700' }[p];
}

export function projectStatusColor(s: ProjectStatus): string {
  return { activo: 'bg-green-100 text-green-700', en_pausa: 'bg-yellow-100 text-yellow-700', terminado: 'bg-gray-100 text-gray-600' }[s];
}

export function projectStatusLabel(s: ProjectStatus): string {
  return { activo: 'Activo', en_pausa: 'En Pausa', terminado: 'Terminado' }[s];
}

export function taskStatusColor(s: TaskStatus): string {
  return { pendiente: 'bg-slate-100 text-slate-700', en_proceso: 'bg-blue-100 text-blue-700', hecho: 'bg-green-100 text-green-700' }[s];
}

export function taskStatusLabel(s: TaskStatus): string {
  return { pendiente: 'Pendiente', en_proceso: 'En Proceso', hecho: 'Hecho' }[s];
}

export function missingStatusColor(s: MissingItemStatus): string {
  return {
    pendiente: 'bg-red-100 text-red-700',
    en_orden: 'bg-yellow-100 text-yellow-700',
    comprado: 'bg-blue-100 text-blue-700',
    entregado: 'bg-green-100 text-green-700',
    instalado: 'bg-emerald-100 text-emerald-800',
  }[s];
}

export function missingStatusLabel(s: MissingItemStatus): string {
  return { pendiente: 'Pendiente', en_orden: 'En Orden', comprado: 'Comprado', entregado: 'Entregado', instalado: 'Instalado' }[s];
}

export function poStatusColor(s: PurchaseOrderStatus): string {
  return { borrador: 'bg-slate-100 text-slate-700', enviado: 'bg-yellow-100 text-yellow-700', comprado: 'bg-blue-100 text-blue-700', entregado: 'bg-green-100 text-green-700' }[s];
}

export function poStatusLabel(s: PurchaseOrderStatus): string {
  return { borrador: 'Borrador', enviado: 'Enviado', comprado: 'Comprado', entregado: 'Entregado' }[s];
}

export function categoryLabel(c: MissingItemCategory): string {
  return { matera: 'Matera', insumo: 'Insumo', planta: 'Planta' }[c];
}

export function categoryIcon(c: MissingItemCategory): string {
  return { matera: '🪴', insumo: '🧪', planta: '🌱' }[c];
}

export function tagColor(t: MediaTag): string {
  const colors: Record<MediaTag, string> = {
    riego: 'bg-cyan-100 text-cyan-700',
    poda: 'bg-lime-100 text-lime-700',
    plagas: 'bg-red-100 text-red-700',
    'instalación': 'bg-purple-100 text-purple-700',
    siembra: 'bg-green-100 text-green-700',
    general: 'bg-gray-100 text-gray-700',
    antes: 'bg-orange-100 text-orange-700',
    durante: 'bg-blue-100 text-blue-700',
    'después': 'bg-emerald-100 text-emerald-700',
  };
  return colors[t];
}

export function genId(): string {
  return Math.random().toString(36).slice(2, 10);
}

export function isOverdue(dateStr: string): boolean {
  return new Date(dateStr) < new Date(new Date().toDateString());
}
