import {
  User, Project, Task, ProjectStaff, MissingItem,
  PurchaseOrder, PurchaseOrderItem, LogMedia
} from '@/types';

export const users: User[] = [
  { id: 'u1', name: 'Carlos Ramírez', role: 'admin', phone: '+57 310 555 1234', email: 'carlos@paisajistaos.co', available: true },
  { id: 'u2', name: 'María López', role: 'supervisor', phone: '+57 311 555 2345', email: 'maria@paisajistaos.co', available: true },
  { id: 'u3', name: 'Juan Pérez', role: 'empleado', phone: '+57 312 555 3456', email: 'juan@paisajistaos.co', available: true },
  { id: 'u4', name: 'Andrés García', role: 'empleado', phone: '+57 313 555 4567', email: 'andres@paisajistaos.co', available: true },
  { id: 'u5', name: 'Luisa Martínez', role: 'empleado', phone: '+57 314 555 5678', email: 'luisa@paisajistaos.co', available: false },
  { id: 'u6', name: 'Pedro Castillo', role: 'empleado', phone: '+57 315 555 6789', email: 'pedro@paisajistaos.co', available: true },
  { id: 'u7', name: 'Diana Rojas', role: 'supervisor', phone: '+57 316 555 7890', email: 'diana@paisajistaos.co', available: true },
];

export const projects: Project[] = [
  {
    id: 'p1', name: 'Jardín Residencia El Poblado', clientName: 'Familia Gómez',
    clientPhone: '+57 300 111 2233', locationText: 'Cra 43A #11Sur-30, El Poblado, Medellín',
    status: 'activo', startDate: '2026-01-15', endDate: '2026-03-15',
    estimatedCost: 18500000, description: 'Diseño e instalación de jardín frontal y posterior con sistema de riego automatizado.',
    createdAt: '2026-01-10',
  },
  {
    id: 'p2', name: 'Terraza Oficinas Chapinero', clientName: 'Inversiones Bogotá SAS',
    clientPhone: '+57 300 222 3344', locationText: 'Calle 72 #10-07, Chapinero, Bogotá',
    status: 'activo', startDate: '2026-01-20', endDate: '2026-02-28',
    estimatedCost: 12000000, description: 'Paisajismo para terraza corporativa piso 8, incluyendo materas grandes y plantas ornamentales.',
    createdAt: '2026-01-18',
  },
  {
    id: 'p3', name: 'Finca La Esperanza - Mantenimiento', clientName: 'Don Hernando Mejía',
    clientPhone: '+57 300 333 4455', locationText: 'Vereda El Retiro, Rionegro, Antioquia',
    status: 'activo', startDate: '2026-02-01', endDate: '2026-12-31',
    estimatedCost: 36000000, description: 'Mantenimiento mensual de jardines, poda, fumigación y reposición de plantas.',
    createdAt: '2026-01-28',
  },
  {
    id: 'p4', name: 'Centro Comercial Plaza Verde', clientName: 'CC Plaza Verde',
    clientPhone: '+57 300 444 5566', locationText: 'Av. El Dorado #68B-85, Bogotá',
    status: 'en_pausa', startDate: '2025-11-01', endDate: '2026-02-15',
    estimatedCost: 45000000, description: 'Paisajismo interior del centro comercial. En pausa por ajustes en diseño arquitectónico.',
    createdAt: '2025-10-20',
  },
  {
    id: 'p5', name: 'Apartamento Rosales', clientName: 'Sra. Patricia Duque',
    locationText: 'Calle 73 #2-45, Rosales, Bogotá',
    status: 'terminado', startDate: '2025-10-01', endDate: '2025-12-20',
    estimatedCost: 8500000, description: 'Balcón y terraza con jardín vertical y materas decorativas.',
    createdAt: '2025-09-25',
  },
];

export const tasks: Task[] = [
  // Proyecto 1 - El Poblado
  { id: 't1', projectId: 'p1', title: 'Preparar terreno jardín frontal', status: 'hecho', priority: 'alta', dueDate: '2026-01-25', assignedUserId: 'u3', createdAt: '2026-01-15' },
  { id: 't2', projectId: 'p1', title: 'Instalar sistema de riego zona A', status: 'en_proceso', priority: 'alta', dueDate: '2026-02-05', assignedUserId: 'u4', createdAt: '2026-01-15' },
  { id: 't3', projectId: 'p1', title: 'Sembrar crotones y heliconias', status: 'pendiente', priority: 'media', dueDate: '2026-02-10', assignedUserId: 'u3', createdAt: '2026-01-15' },
  { id: 't4', projectId: 'p1', title: 'Instalar materas decorativas entrada', status: 'pendiente', priority: 'media', dueDate: '2026-02-15', createdAt: '2026-01-15' },
  { id: 't5', projectId: 'p1', title: 'Colocar piedra decorativa sendero', status: 'pendiente', priority: 'baja', dueDate: '2026-02-20', createdAt: '2026-01-15' },
  { id: 't6', projectId: 'p1', title: 'Instalar iluminación jardín', status: 'pendiente', priority: 'baja', dueDate: '2026-03-01', assignedUserId: 'u6', createdAt: '2026-01-15' },
  // Proyecto 2 - Chapinero
  { id: 't7', projectId: 'p2', title: 'Subir materas al piso 8', status: 'hecho', priority: 'alta', dueDate: '2026-01-28', assignedUserId: 'u4', createdAt: '2026-01-20' },
  { id: 't8', projectId: 'p2', title: 'Instalar impermeabilización materas', status: 'hecho', priority: 'alta', dueDate: '2026-01-30', assignedUserId: 'u6', createdAt: '2026-01-20' },
  { id: 't9', projectId: 'p2', title: 'Sembrar palmas areca', status: 'en_proceso', priority: 'alta', dueDate: '2026-02-03', assignedUserId: 'u3', createdAt: '2026-01-20' },
  { id: 't10', projectId: 'p2', title: 'Instalar sistema de riego por goteo', status: 'pendiente', priority: 'media', dueDate: '2026-02-10', createdAt: '2026-01-20' },
  { id: 't11', projectId: 'p2', title: 'Colocar grava blanca decorativa', status: 'pendiente', priority: 'baja', dueDate: '2026-02-15', createdAt: '2026-01-20' },
  // Proyecto 3 - Finca
  { id: 't12', projectId: 'p3', title: 'Poda general febrero', status: 'en_proceso', priority: 'alta', dueDate: '2026-02-07', assignedUserId: 'u4', createdAt: '2026-02-01' },
  { id: 't13', projectId: 'p3', title: 'Fumigación zona de frutales', status: 'pendiente', priority: 'alta', dueDate: '2026-02-10', assignedUserId: 'u6', createdAt: '2026-02-01' },
  { id: 't14', projectId: 'p3', title: 'Fertilización jardín principal', status: 'pendiente', priority: 'media', dueDate: '2026-02-15', createdAt: '2026-02-01' },
  { id: 't15', projectId: 'p3', title: 'Reposición de plantas dañadas', status: 'pendiente', priority: 'media', dueDate: '2026-02-20', createdAt: '2026-02-01' },
];

export const projectStaff: ProjectStaff[] = [
  { projectId: 'p1', userId: 'u3', dateAssigned: '2026-01-15', checkedIn: true, checkInTime: '07:30' },
  { projectId: 'p1', userId: 'u4', dateAssigned: '2026-01-15', checkedIn: true, checkInTime: '07:45' },
  { projectId: 'p1', userId: 'u6', dateAssigned: '2026-02-01', checkedIn: false },
  { projectId: 'p2', userId: 'u3', dateAssigned: '2026-01-20', checkedIn: false },
  { projectId: 'p2', userId: 'u6', dateAssigned: '2026-01-20', checkedIn: true, checkInTime: '08:00' },
  { projectId: 'p3', userId: 'u4', dateAssigned: '2026-02-01', checkedIn: true, checkInTime: '06:30' },
  { projectId: 'p3', userId: 'u6', dateAssigned: '2026-02-01', checkedIn: false },
];

export const missingItems: MissingItem[] = [
  { id: 'm1', projectId: 'p1', category: 'planta', name: 'Crotones grandes', qty: 15, priority: 'alta', neededBy: '2026-02-08', status: 'pendiente', supplier: 'Vivero El Jardín' },
  { id: 'm2', projectId: 'p1', category: 'planta', name: 'Heliconias rojas', qty: 8, priority: 'alta', neededBy: '2026-02-08', status: 'en_orden', supplier: 'Vivero El Jardín', purchaseOrderId: 'po1' },
  { id: 'm3', projectId: 'p1', category: 'insumo', name: 'Sustrato orgánico (bultos)', qty: 20, priority: 'media', neededBy: '2026-02-10', status: 'pendiente' },
  { id: 'm4', projectId: 'p1', category: 'matera', name: 'Materas fibrocemento 60cm', qty: 6, priority: 'media', neededBy: '2026-02-12', status: 'pendiente', supplier: 'Homecenter' },
  { id: 'm5', projectId: 'p1', category: 'insumo', name: 'Piedra río blanca (m³)', qty: 3, priority: 'baja', neededBy: '2026-02-18', status: 'pendiente' },
  { id: 'm6', projectId: 'p2', category: 'planta', name: 'Palmas Areca 1.5m', qty: 10, priority: 'alta', neededBy: '2026-02-03', status: 'comprado', supplier: 'Vivero Paraíso' },
  { id: 'm7', projectId: 'p2', category: 'insumo', name: 'Kit riego por goteo', qty: 2, priority: 'media', neededBy: '2026-02-08', status: 'pendiente' },
  { id: 'm8', projectId: 'p2', category: 'insumo', name: 'Grava blanca decorativa (m³)', qty: 2, priority: 'baja', neededBy: '2026-02-12', status: 'pendiente' },
  { id: 'm9', projectId: 'p3', category: 'insumo', name: 'Fertilizante triple 15 (bultos)', qty: 5, priority: 'alta', neededBy: '2026-02-13', status: 'pendiente' },
  { id: 'm10', projectId: 'p3', category: 'insumo', name: 'Insecticida orgánico (litros)', qty: 10, priority: 'alta', neededBy: '2026-02-09', status: 'pendiente', supplier: 'AgroInsumos' },
  { id: 'm11', projectId: 'p3', category: 'planta', name: 'Duranta limón (reposición)', qty: 12, priority: 'media', neededBy: '2026-02-18', status: 'pendiente', supplier: 'Vivero El Jardín' },
];

export const purchaseOrders: PurchaseOrder[] = [
  { id: 'po1', projectId: 'p1', supplierName: 'Vivero El Jardín', status: 'enviado', totalEstimated: 960000, createdAt: '2026-02-01' },
  { id: 'po2', projectId: 'p2', supplierName: 'Vivero Paraíso', status: 'comprado', totalEstimated: 1500000, createdAt: '2026-01-25' },
];

export const purchaseOrderItems: PurchaseOrderItem[] = [
  { id: 'poi1', purchaseOrderId: 'po1', name: 'Heliconias rojas', qty: 8, unitCostEst: 45000 },
  { id: 'poi2', purchaseOrderId: 'po1', name: 'Abono orgánico', qty: 5, unitCostEst: 72000 },
  { id: 'poi3', purchaseOrderId: 'po2', name: 'Palmas Areca 1.5m', qty: 10, unitCostEst: 120000 },
  { id: 'poi4', purchaseOrderId: 'po2', name: 'Sustrato premium', qty: 10, unitCostEst: 30000 },
];

export const logMedia: LogMedia[] = [
  { id: 'lm1', projectId: 'p1', url: '/placeholder-garden-1.jpg', caption: 'Terreno antes de iniciar - jardín frontal', tags: ['antes', 'general'], createdBy: 'u2', createdAt: '2026-01-15T08:30:00' },
  { id: 'lm2', projectId: 'p1', url: '/placeholder-garden-2.jpg', caption: 'Preparación del terreno completada', tags: ['durante', 'instalación'], createdBy: 'u3', createdAt: '2026-01-25T16:00:00' },
  { id: 'lm3', projectId: 'p1', url: '/placeholder-garden-3.jpg', caption: 'Inicio instalación sistema de riego', tags: ['durante', 'riego'], createdBy: 'u4', createdAt: '2026-02-01T10:15:00' },
  { id: 'lm4', projectId: 'p2', url: '/placeholder-terrace-1.jpg', caption: 'Terraza antes del proyecto', tags: ['antes', 'general'], createdBy: 'u2', createdAt: '2026-01-20T09:00:00' },
  { id: 'lm5', projectId: 'p2', url: '/placeholder-terrace-2.jpg', caption: 'Materas instaladas en piso 8', tags: ['durante', 'instalación'], createdBy: 'u6', createdAt: '2026-01-28T15:30:00' },
  { id: 'lm6', projectId: 'p2', url: '/placeholder-terrace-3.jpg', caption: 'Palmas areca sembradas', tags: ['durante', 'siembra'], createdBy: 'u3', createdAt: '2026-02-02T11:45:00' },
  { id: 'lm7', projectId: 'p3', url: '/placeholder-finca-1.jpg', caption: 'Estado general finca - inicio febrero', tags: ['antes', 'general'], createdBy: 'u7', createdAt: '2026-02-01T07:00:00' },
  { id: 'lm8', projectId: 'p3', url: '/placeholder-finca-2.jpg', caption: 'Poda de setos en progreso', tags: ['durante', 'poda'], createdBy: 'u4', createdAt: '2026-02-03T14:20:00' },
];
