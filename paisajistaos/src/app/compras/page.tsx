'use client';

import React from 'react';
import { useApp } from '@/lib/context';
import { Card, CardContent } from '@/components/ui/Card';
import Badge from '@/components/ui/Badge';
import { ShoppingCart, FileText, Send } from 'lucide-react';
import { poStatusColor, poStatusLabel, formatDate, formatCOP } from '@/lib/utils';
import { PurchaseOrderStatus } from '@/types';

export default function ComprasPage() {
  const { state, updatePurchaseOrderStatus } = useApp();
  const { purchaseOrders, purchaseOrderItems, projects } = state;

  const statusFlow: PurchaseOrderStatus[] = ['borrador', 'enviado', 'comprado', 'entregado'];

  const advanceStatus = (poId: string, current: PurchaseOrderStatus) => {
    const idx = statusFlow.indexOf(current);
    if (idx < statusFlow.length - 1) {
      updatePurchaseOrderStatus(poId, statusFlow[idx + 1]);
    }
  };

  const shareToWhatsApp = (po: typeof purchaseOrders[0]) => {
    const items = purchaseOrderItems.filter(i => i.purchaseOrderId === po.id);
    const project = projects.find(p => p.id === po.projectId);
    const itemsList = items.map(i => `  - ${i.name} x${i.qty}`).join('\n');
    const text = `*Orden de Compra - ${project?.name}*\n\nProveedor: ${po.supplierName}\nEstado: ${poStatusLabel(po.status)}\n\nItems:\n${itemsList}\n\nTotal estimado: ${formatCOP(po.totalEstimated)}\n\n_PaisajistaOS_`;
    window.open(`https://wa.me/?text=${encodeURIComponent(text)}`, '_blank');
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Órdenes de Compra</h1>
        <p className="text-gray-500 text-sm mt-1">{purchaseOrders.length} órdenes registradas</p>
      </div>

      {purchaseOrders.length === 0 ? (
        <Card>
          <CardContent className="text-center py-12">
            <ShoppingCart className="w-12 h-12 text-gray-300 mx-auto mb-3" />
            <p className="text-gray-500">No hay órdenes de compra</p>
            <p className="text-sm text-gray-400 mt-1">Crea una desde los faltantes de un proyecto</p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {purchaseOrders.map(po => {
            const project = projects.find(p => p.id === po.projectId);
            const items = purchaseOrderItems.filter(i => i.purchaseOrderId === po.id);
            const total = items.reduce((sum, i) => sum + i.qty * i.unitCostEst, 0);

            return (
              <Card key={po.id}>
                <div className="px-4 py-3 border-b border-gray-100 flex items-center justify-between flex-wrap gap-2">
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold text-gray-900">{po.supplierName}</h3>
                      <Badge className={poStatusColor(po.status)}>{poStatusLabel(po.status)}</Badge>
                    </div>
                    <p className="text-xs text-gray-500 mt-0.5">
                      {project?.name} · Creada: {formatDate(po.createdAt)}
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => shareToWhatsApp(po)}
                      className="flex items-center gap-1 text-xs bg-green-600 text-white px-3 py-1.5 rounded-lg hover:bg-green-700"
                    >
                      <Send className="w-3 h-3" /> WhatsApp
                    </button>
                    {po.status !== 'entregado' && (
                      <button
                        onClick={() => advanceStatus(po.id, po.status)}
                        className="flex items-center gap-1 text-xs bg-primary-600 text-white px-3 py-1.5 rounded-lg hover:bg-primary-700"
                      >
                        Avanzar estado
                      </button>
                    )}
                  </div>
                </div>
                <CardContent>
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="text-left text-xs text-gray-500 border-b">
                        <th className="pb-2">Item</th>
                        <th className="pb-2 text-right">Cant.</th>
                        <th className="pb-2 text-right">Costo unit.</th>
                        <th className="pb-2 text-right">Subtotal</th>
                      </tr>
                    </thead>
                    <tbody>
                      {items.map(item => (
                        <tr key={item.id} className="border-b border-gray-50">
                          <td className="py-2">{item.name}</td>
                          <td className="py-2 text-right">{item.qty}</td>
                          <td className="py-2 text-right">{formatCOP(item.unitCostEst)}</td>
                          <td className="py-2 text-right">{formatCOP(item.qty * item.unitCostEst)}</td>
                        </tr>
                      ))}
                    </tbody>
                    <tfoot>
                      <tr className="font-semibold">
                        <td colSpan={3} className="pt-2 text-right">Total estimado:</td>
                        <td className="pt-2 text-right">{formatCOP(total || po.totalEstimated)}</td>
                      </tr>
                    </tfoot>
                  </table>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
