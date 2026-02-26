import SwiftUI

struct ProjectFaltantesTab: View {
    let project: Project
    @EnvironmentObject var dataManager: DataManager
    @State private var showNewItem = false

    var pendingItems: [MissingItem] {
        dataManager.getMissingItems(for: project.id).filter { $0.status == .pendiente }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Action Buttons
                HStack {
                    if !pendingItems.isEmpty {
                        Button {
                            dataManager.createPurchaseOrder(
                                from: pendingItems,
                                projectId: project.id,
                                supplierName: pendingItems.first?.supplier ?? "Por definir"
                            )
                        } label: {
                            Label("Crear Orden", systemImage: "cart.badge.plus")
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }

                    Spacer()

                    Button {
                        showNewItem = true
                    } label: {
                        Label("Agregar", systemImage: "plus")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                // Items List
                let items = dataManager.getMissingItems(for: project.id)

                if items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No hay faltantes registrados")
                            .foregroundColor(.secondary)
                        Button("Agregar el primero") {
                            showNewItem = true
                        }
                        .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ForEach(items) { item in
                        MissingItemRow(item: item)
                    }
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showNewItem) {
            NewMissingItemView(projectId: project.id)
        }
    }
}

struct MissingItemRow: View {
    let item: MissingItem
    @EnvironmentObject var dataManager: DataManager

    var statusColor: Color {
        switch item.status {
        case .pendiente: return .red
        case .enOrden: return .orange
        case .comprado: return .blue
        case .entregado: return .green
        case .instalado: return .green
        }
    }

    var body: some View {
        HStack {
            Image(systemName: item.category.icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.bold())
                HStack {
                    Text(item.category.label)
                    Text("·")
                    Text("Cant: \(item.qty)")
                    Text("·")
                    Text(item.neededBy, style: .date)
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if let supplier = item.supplier {
                    Text(supplier)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                PriorityBadge(priority: item.priority)

                Menu {
                    ForEach(MissingItemStatus.allCases, id: \.self) { status in
                        Button {
                            var updated = item
                            updated.status = status
                            dataManager.updateMissingItem(updated)
                        } label: {
                            Label(status.label, systemImage: item.status == status ? "checkmark" : "")
                        }
                    }
                } label: {
                    Text(item.status.label)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ProjectFaltantesTab(project: DataManager().projects[0])
        .environmentObject(DataManager())
}
