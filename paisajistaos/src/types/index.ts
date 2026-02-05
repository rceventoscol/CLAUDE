export type UserRole = 'admin' | 'supervisor' | 'empleado' | 'cliente';

export interface User {
  id: string;
  name: string;
  role: UserRole;
  phone: string;
  email: string;
  avatar?: string;
  available: boolean;
}

export type ProjectStatus = 'activo' | 'en_pausa' | 'terminado';

export interface Project {
  id: string;
  name: string;
  clientName: string;
  clientPhone?: string;
  locationText: string;
  status: ProjectStatus;
  startDate: string;
  endDate: string;
  estimatedCost?: number;
  description?: string;
  createdAt: string;
}

export type TaskStatus = 'pendiente' | 'en_proceso' | 'hecho';
export type Priority = 'alta' | 'media' | 'baja';

export interface Task {
  id: string;
  projectId: string;
  title: string;
  description?: string;
  status: TaskStatus;
  priority: Priority;
  dueDate: string;
  assignedUserId?: string;
  createdAt: string;
}

export interface ProjectStaff {
  projectId: string;
  userId: string;
  dateAssigned: string;
  checkedIn: boolean;
  checkInTime?: string;
}

export type MissingItemCategory = 'matera' | 'insumo' | 'planta';
export type MissingItemStatus = 'pendiente' | 'en_orden' | 'comprado' | 'entregado' | 'instalado';

export interface MissingItem {
  id: string;
  projectId: string;
  category: MissingItemCategory;
  name: string;
  qty: number;
  priority: Priority;
  neededBy: string;
  status: MissingItemStatus;
  supplier?: string;
  purchaseOrderId?: string;
}

export type PurchaseOrderStatus = 'borrador' | 'enviado' | 'comprado' | 'entregado';

export interface PurchaseOrder {
  id: string;
  projectId: string;
  supplierName: string;
  status: PurchaseOrderStatus;
  totalEstimated: number;
  createdAt: string;
  receiptUrl?: string;
}

export interface PurchaseOrderItem {
  id: string;
  purchaseOrderId: string;
  name: string;
  qty: number;
  unitCostEst: number;
}

export type MediaTag = 'riego' | 'poda' | 'plagas' | 'instalación' | 'siembra' | 'general' | 'antes' | 'durante' | 'después';

export interface LogMedia {
  id: string;
  projectId: string;
  url: string;
  caption: string;
  tags: MediaTag[];
  createdBy: string;
  createdAt: string;
}
