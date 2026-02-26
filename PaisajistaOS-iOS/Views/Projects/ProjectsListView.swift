import SwiftUI

struct ProjectsListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedFilter: ProjectStatus? = nil
    @State private var showNewProject = false

    var filteredProjects: [Project] {
        if let filter = selectedFilter {
            return dataManager.projects.filter { $0.status == filter }
        }
        return dataManager.projects
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(title: "Todos", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        ForEach(ProjectStatus.allCases, id: \.self) { status in
                            FilterPill(title: status.label, isSelected: selectedFilter == status) {
                                selectedFilter = status
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))

                // Projects List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredProjects) { project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                ProjectCard(project: project, dataManager: dataManager)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Proyectos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewProject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewProject) {
                NewProjectView()
            }
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ProjectCard: View {
    let project: Project
    let dataManager: DataManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                    Text(project.clientName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge(text: project.status.label, color: statusColor(project.status))
            }

            HStack {
                Image(systemName: "mappin")
                Text(project.locationText)
                    .lineLimit(1)
            }
            .font(.caption)
            .foregroundColor(.secondary)

            let progress = dataManager.getProjectProgress(projectId: project.id)
            HStack {
                Text("Progreso")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.green)
            }
            ProgressView(value: progress)
                .tint(.green)

            HStack {
                Image(systemName: "calendar")
                Text("\(project.startDate, style: .date) - \(project.endDate, style: .date)")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            HStack(spacing: 8) {
                let taskCount = dataManager.getTasks(for: project.id).count
                let missingCount = dataManager.getMissingItems(for: project.id).filter { $0.status == .pendiente }.count

                Label("\(taskCount) tareas", systemImage: "checklist")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(4)

                if missingCount > 0 {
                    Label("\(missingCount) faltantes", systemImage: "shippingbox")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }

                Spacer()

                if let cost = project.estimatedCost {
                    Text(formatCOP(cost))
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    func statusColor(_ status: ProjectStatus) -> Color {
        switch status {
        case .activo: return .green
        case .enPausa: return .orange
        case .terminado: return .gray
        }
    }
}

func formatCOP(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "COP"
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
}

#Preview {
    ProjectsListView()
        .environmentObject(DataManager())
}
