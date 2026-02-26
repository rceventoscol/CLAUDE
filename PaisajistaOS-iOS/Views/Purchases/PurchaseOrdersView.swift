import SwiftUI

struct PurchaseOrdersView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if dataManager.purchaseOrders.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No hay órdenes de compra")
                            .foregroundColor(.secondary)
                        Text("Crea una desde los faltantes de un proyecto")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ForEach(dataManager.purchaseOrders) { po in
                        PurchaseOrderCard(purchaseOrder: po)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Órdenes de Compra")
    }
}

struct PurchaseOrderCard: View {
    let purchaseOrder: PurchaseOrder
    @EnvironmentObject var dataManager: DataManager

    var items: [PurchaseOrderItem] {
        dataManager.purchaseOrderItems.filter { $0.purchaseOrderId == purchaseOrder.id }
    }

    var statusColor: Color {
        switch purchaseOrder.status {
        case .borrador: return .gray
        case .enviado: return .orange
        case .comprado: return .blue
        case .entregado: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(purchaseOrder.supplierName)
                            .font(.headline)
                        Text(purchaseOrder.status.label)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.2))
                            .foregroundColor(statusColor)
                            .cornerRadius(4)
                    }
                    if let project = dataManager.getProject(by: purchaseOrder.projectId) {
                        HStack {
                            Text(project.name)
                            Text("·")
                            Text("Creada: \(purchaseOrder.createdAt, style: .date)")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }

            // Action Buttons
            HStack {
                Button {
                    shareOnWhatsApp()
                } label: {
                    Label("WhatsApp", systemImage: "paperplane.fill")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }

                if purchaseOrder.status != .entregado {
                    Button {
                        dataManager.advancePurchaseOrderStatus(purchaseOrder.id)
                    } label: {
                        Text("Avanzar estado")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
            }

            Divider()

            // Items Table
            VStack(spacing: 8) {
                HStack {
                    Text("Item")
                        .fontWeight(.medium)
                    Spacer()
                    Text("Cant.")
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .trailing)
                    Text("Costo")
                        .fontWeight(.medium)
                        .frame(width: 80, alignment: .trailing)
                    Text("Subtotal")
                        .fontWeight(.medium)
                        .frame(width: 90, alignment: .trailing)
                }
                .font(.caption)
                .foregroundColor(.secondary)

                ForEach(items) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("\(item.qty)")
                            .frame(width: 50, alignment: .trailing)
                        Text(formatCOP(item.unitCostEst))
                            .frame(width: 80, alignment: .trailing)
                        Text(formatCOP(Double(item.qty) * item.unitCostEst))
                            .frame(width: 90, alignment: .trailing)
                    }
                    .font(.caption)
                }

                Divider()

                HStack {
                    Spacer()
                    Text("Total estimado:")
                        .fontWeight(.bold)
                    Text(formatCOP(calculateTotal()))
                        .fontWeight(.bold)
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    func calculateTotal() -> Double {
        items.reduce(0) { $0 + Double($1.qty) * $1.unitCostEst }
    }

    func shareOnWhatsApp() {
        guard let project = dataManager.getProject(by: purchaseOrder.projectId) else { return }

        let itemsList = items.map { "  - \($0.name) x\($0.qty)" }.joined(separator: "\n")

        let text = """
        *Orden de Compra - \(project.name)*

        Proveedor: \(purchaseOrder.supplierName)
        Estado: \(purchaseOrder.status.label)

        Items:
        \(itemsList)

        Total estimado: \(formatCOP(calculateTotal()))

        _PaisajistaOS_
        """

        if let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://wa.me/?text=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack {
        PurchaseOrdersView()
            .environmentObject(DataManager())
    }
}
