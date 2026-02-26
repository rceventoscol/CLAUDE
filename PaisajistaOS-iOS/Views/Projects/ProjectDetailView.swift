import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            VStack(spacing: 8) {
                let progress = dataManager.getProjectProgress(projectId: project.id)
                let tasks = dataManager.getTasks(for: project.id)
                let done = tasks.filter { $0.status == .hecho }.count

                HStack {
                    Text("Progreso general")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                }
                ProgressView(value: progress)
                    .tint(.green)
                Text("\(done) de \(tasks.count) tareas completadas")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))

            // Tab Picker
            Picker("Tab", selection: $selectedTab) {
                Text("Resumen").tag(0)
                Text("Tareas").tag(1)
                Text("Equipo").tag(2)
                Text("Faltantes").tag(3)
                Text("Fotos").tag(4)
            }
            .pickerStyle(.segmented)
            .padding()

            // Tab Content
            TabView(selection: $selectedTab) {
                ProjectSummaryTab(project: project)
                    .tag(0)
                ProjectTasksTab(project: project)
                    .tag(1)
                ProjectStaffTab(project: project)
                    .tag(2)
                ProjectFaltantesTab(project: project)
                    .tag(3)
                ProjectBitacoraTab(project: project)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    shareOnWhatsApp()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    func shareOnWhatsApp() {
        let progress = Int(dataManager.getProjectProgress(projectId: project.id) * 100)
        let tasks = dataManager.getTasks(for: project.id)
        let done = tasks.filter { $0.status == .hecho }.count
        let missing = dataManager.getMissingItems(for: project.id).filter { $0.status == .pendiente }.count

        let text = """
        *Avance: \(project.name)*

        Cliente: \(project.clientName)
        Progreso: \(progress)%
        Tareas completadas: \(done)/\(tasks.count)
        Faltantes pendientes: \(missing)

        _Generado por PaisajistaOS_
        """

        if let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://wa.me/?text=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ProjectSummaryTab: View {
    let project: Project
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Info Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    SummaryCard(title: "Tareas", items: [
                        ("Pendientes", "\(dataManager.getTasks(for: project.id).filter { $0.status == .pendiente }.count)"),
                        ("En proceso", "\(dataManager.getTasks(for: project.id).filter { $0.status == .enProceso }.count)"),
                        ("Completadas", "\(dataManager.getTasks(for: project.id).filter { $0.status == .hecho }.count)")
                    ])

                    SummaryCard(title: "Faltantes", items: [
                        ("Pendientes", "\(dataManager.getMissingItems(for: project.id).filter { $0.status == .pendiente }.count)"),
                        ("En orden", "\(dataManager.getMissingItems(for: project.id).filter { $0.status == .enOrden || $0.status == .comprado }.count)"),
                        ("Entregados", "\(dataManager.getMissingItems(for: project.id).filter { $0.status == .entregado || $0.status == .instalado }.count)")
                    ])
                }

                // Details
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(icon: "person", label: "Cliente", value: project.clientName)
                    if let phone = project.clientPhone {
                        DetailRow(icon: "phone", label: "Teléfono", value: phone)
                    }
                    DetailRow(icon: "mappin", label: "Ubicación", value: project.locationText)
                    DetailRow(icon: "calendar", label: "Inicio", value: project.startDate.formatted(date: .abbreviated, time: .omitted))
                    DetailRow(icon: "calendar.badge.checkmark", label: "Entrega", value: project.endDate.formatted(date: .abbreviated, time: .omitted))
                    if let cost = project.estimatedCost {
                        DetailRow(icon: "dollarsign.circle", label: "Presupuesto", value: formatCOP(cost))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)

                if let description = project.description {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.headline)
                        Text(description)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

struct SummaryCard: View {
    let title: String
    let items: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            ForEach(items, id: \.0) { item in
                HStack {
                    Text(item.0)
                        .font(.caption)
                    Spacer()
                    Text(item.1)
                        .font(.caption.bold())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: DataManager().projects[0])
            .environmentObject(DataManager())
    }
}
