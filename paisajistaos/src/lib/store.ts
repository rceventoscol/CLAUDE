'use client';

import { useState, useCallback } from 'react';
import {
  User, Project, Task, ProjectStaff, MissingItem,
  PurchaseOrder, PurchaseOrderItem, LogMedia
} from '@/types';
import * as seed from '@/data/seed';

export interface AppState {
  users: User[];
  projects: Project[];
  tasks: Task[];
  projectStaff: ProjectStaff[];
  missingItems: MissingItem[];
  purchaseOrders: PurchaseOrder[];
  purchaseOrderItems: PurchaseOrderItem[];
  logMedia: LogMedia[];
}

const initialState: AppState = {
  users: seed.users,
  projects: seed.projects,
  tasks: seed.tasks,
  projectStaff: seed.projectStaff,
  missingItems: seed.missingItems,
  purchaseOrders: seed.purchaseOrders,
  purchaseOrderItems: seed.purchaseOrderItems,
  logMedia: seed.logMedia,
};

export function useAppState() {
  const [state, setState] = useState<AppState>(initialState);

  const updateTasks = useCallback((updater: (tasks: Task[]) => Task[]) => {
    setState(prev => ({ ...prev, tasks: updater(prev.tasks) }));
  }, []);

  const addTask = useCallback((task: Task) => {
    setState(prev => ({ ...prev, tasks: [...prev.tasks, task] }));
  }, []);

  const updateMissingItems = useCallback((updater: (items: MissingItem[]) => MissingItem[]) => {
    setState(prev => ({ ...prev, missingItems: updater(prev.missingItems) }));
  }, []);

  const addMissingItem = useCallback((item: MissingItem) => {
    setState(prev => ({ ...prev, missingItems: [...prev.missingItems, item] }));
  }, []);

  const addPurchaseOrder = useCallback((po: PurchaseOrder, items: PurchaseOrderItem[]) => {
    setState(prev => ({
      ...prev,
      purchaseOrders: [...prev.purchaseOrders, po],
      purchaseOrderItems: [...prev.purchaseOrderItems, ...items],
      missingItems: prev.missingItems.map(mi =>
        items.some(i => i.name === mi.name && mi.projectId === po.projectId)
          ? { ...mi, status: 'en_orden' as const, purchaseOrderId: po.id }
          : mi
      ),
    }));
  }, []);

  const updatePurchaseOrderStatus = useCallback((poId: string, status: PurchaseOrder['status']) => {
    setState(prev => ({
      ...prev,
      purchaseOrders: prev.purchaseOrders.map(po => po.id === poId ? { ...po, status } : po),
    }));
  }, []);

  const addLogMedia = useCallback((media: LogMedia) => {
    setState(prev => ({ ...prev, logMedia: [...prev.logMedia, media] }));
  }, []);

  const updateProjectStaff = useCallback((updater: (staff: ProjectStaff[]) => ProjectStaff[]) => {
    setState(prev => ({ ...prev, projectStaff: updater(prev.projectStaff) }));
  }, []);

  const addProject = useCallback((project: Project) => {
    setState(prev => ({ ...prev, projects: [...prev.projects, project] }));
  }, []);

  const updateProject = useCallback((id: string, updates: Partial<Project>) => {
    setState(prev => ({
      ...prev,
      projects: prev.projects.map(p => p.id === id ? { ...p, ...updates } : p),
    }));
  }, []);

  return {
    state,
    updateTasks,
    addTask,
    updateMissingItems,
    addMissingItem,
    addPurchaseOrder,
    updatePurchaseOrderStatus,
    addLogMedia,
    updateProjectStaff,
    addProject,
    updateProject,
  };
}
