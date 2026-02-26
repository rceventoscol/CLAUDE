import SwiftUI

struct FaltantesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var filterStatus: MissingItemStatus? = nil
    @State private var filterPriority: Priority? = nil

    var filteredItems: [MissingItem] {
        var items = dataManager.missingItems
        if let status = filterStatus {
            items = items.filter { $0.status == status }
        }
        if let priority = filterPriority {
            items = items.filter { $0.priority == priority }
        }
        return items
    }

    var groupedByProject: [String: [MissingItem]] {
        Dictionary(grouping: filteredItems, by: { $0.projectId })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Urgent Alert
                let urgentCount = dataManager.urgentMissingItems.count
                if urgentCount > 0 {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("\(urgentCount) faltantes urgentes sin orden")
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                }

                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Text("Estado:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        FilterPill(title: "Todos", isSelected: filterStatus == nil) {
                            filterStatus = nil
                        }
                        ForEach(MissingItemStatus.allCases, id: \.self) { status in
                            FilterPill(title: status.label, isSelected: filterStatus == status) {
                                filterStatus = status
                            }
                        }

                        Divider()
                            .frame(height: 20)

                        Text("Prioridad:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(Priority.allCases, id: \.self) { priority in
                            FilterPill(title: priority.label, isSelected: filterPriority == priority) {
                                filterPriority = filterPriority == priority ? nil : priority
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))

                // Items List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(groupedByProject.keys.sorted()), id: \.self) { projectId in
                            if let project = dataManager.getProject(by: projectId),
                               let items = groupedByProject[projectId] {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(project.name)
                                            .font(.headline)
                                        Spacer()
                                        Text("\(items.count) items")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)

                                    ForEach(items) { item in
                                        FaltanteRow(item: item)
                                    }
                                }
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Faltantes")
        }
    }
}

struct FaltanteRow: View {
    let item: MissingItem
    @EnvironmentObject var dataManager: DataManager

    var statusColor: Color {
        switch item.status {
        case .pendiente: return .red
        case .enOrden: return .orange
        case .comprado: return .blue
        case .entregado, .instalado: return .green
        }
    }

    var body: some View {
        HStack {
            Image(systemName: item.category.icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.bold())
                HStack {
                    Text(item.category.label)
                    Text("·")
                    Text("x\(item.qty)")
                    Text("·")
                    Text(item.neededBy, style: .date)
                    if let supplier = item.supplier {
                        Text("·")
                        Text(supplier)
                            .foregroundColor(.blue)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
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
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    FaltantesView()
        .environmentObject(DataManager())
}
