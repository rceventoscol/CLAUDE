import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // KPI Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        KPICard(
                            title: "Proyectos Activos",
                            value: "\(dataManager.activeProjects.count)",
                            icon: "folder.fill",
                            color: .green
                        )
                        KPICard(
                            title: "Tareas Vencidas",
                            value: "\(dataManager.overdueTasks.count)",
                            icon: "exclamationmark.triangle.fill",
                            color: .red
                        )
                        KPICard(
                            title: "Faltantes Urgentes",
                            value: "\(dataManager.urgentMissingItems.count)",
                            icon: "shippingbox.fill",
                            color: .orange
                        )
                        KPICard(
                            title: "En Obra Hoy",
                            value: "\(dataManager.checkedInStaff.count)",
                            icon: "person.2.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)

                    // Projects at Risk
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Proyectos en Riesgo")
                                .font(.headline)
                            Spacer()
                        }

                        let atRiskProjects = dataManager.activeProjects.filter { dataManager.isProjectAtRisk($0.id) }

                        if atRiskProjects.isEmpty {
                            Text("No hay proyectos en riesgo")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(atRiskProjects) { project in
                                NavigationLink(destination: ProjectDetailView(project: project)) {
                                    ProjectRiskCard(project: project, dataManager: dataManager)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)

                    // Who is Where Today
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Quién está dónde hoy")
                                .font(.headline)
                            Spacer()
                        }

                        if dataManager.checkedInStaff.isEmpty {
                            Text("Nadie ha registrado check-in hoy")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(dataManager.checkedInStaff, id: \.id) { staff in
                                if let user = dataManager.getUser(by: staff.userId),
                                   let project = dataManager.getProject(by: staff.projectId) {
                                    HStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Text(user.initials)
                                                    .font(.caption.bold())
                                                    .foregroundColor(.green)
                                            )
                                        VStack(alignment: .leading) {
                                            Text(user.name)
                                                .font(.subheadline.bold())
                                            Text(project.name)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if let time = staff.checkInTime {
                                            Text(time)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)

                    // Active Projects
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Proyectos Activos")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(dataManager.activeProjects) { project in
                                    NavigationLink(destination: ProjectDetailView(project: project)) {
                                        ActiveProjectCard(project: project, dataManager: dataManager)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
        }
    }
}

struct KPICard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct ProjectRiskCard: View {
    let project: Project
    let dataManager: DataManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(project.name)
                        .font(.subheadline.bold())
                    Text(project.clientName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge(text: project.status.label, color: statusColor(project.status))
            }

            let progress = dataManager.getProjectProgress(projectId: project.id)
            ProgressView(value: progress)
                .tint(.green)

            HStack {
                let overdue = dataManager.getTasks(for: project.id).filter { $0.status != .hecho && $0.dueDate < Date() }.count
                let urgent = dataManager.getMissingItems(for: project.id).filter { $0.priority == .alta && $0.status == .pendiente }.count

                if overdue > 0 {
                    Text("\(overdue) vencidas")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                if urgent > 0 {
                    Text("\(urgent) urgentes")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }

    func statusColor(_ status: ProjectStatus) -> Color {
        switch status {
        case .activo: return .green
        case .enPausa: return .orange
        case .terminado: return .gray
        }
    }
}

struct ActiveProjectCard: View {
    let project: Project
    let dataManager: DataManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(project.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Spacer()
                Text("\(Int(dataManager.getProjectProgress(projectId: project.id) * 100))%")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            Text(project.clientName)
                .font(.caption)
                .foregroundColor(.secondary)

            ProgressView(value: dataManager.getProjectProgress(projectId: project.id))
                .tint(.green)

            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(project.endDate, style: .date)
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataManager())
}
