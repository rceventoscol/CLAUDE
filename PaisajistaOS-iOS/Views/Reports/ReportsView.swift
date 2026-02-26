import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedProjectId: String = ""

    var selectedProject: Project? {
        dataManager.getProject(by: selectedProjectId)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Project Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Seleccionar proyecto")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Menu {
                        ForEach(dataManager.projects) { project in
                            Button("\(project.name) - \(project.clientName)") {
                                selectedProjectId = project.id
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedProject?.name ?? "Selecciona un proyecto")
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding()

                if let project = selectedProject {
                    // Send WhatsApp Button
                    Button {
                        sendWhatsAppReport(project: project)
                    } label: {
                        Label("Enviar por WhatsApp", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // Report Preview
                    ReportPreview(project: project, dataManager: dataManager)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reportes")
        .onAppear {
            if selectedProjectId.isEmpty, let first = dataManager.projects.first {
                selectedProjectId = first.id
            }
        }
    }

    func sendWhatsAppReport(project: Project) {
        let progress = Int(dataManager.getProjectProgress(projectId: project.id) * 100)
        let tasks = dataManager.getTasks(for: project.id)
        let done = tasks.filter { $0.status == .hecho }
        let inProgress = tasks.filter { $0.status == .enProceso }
        let pendingMissing = dataManager.getMissingItems(for: project.id).filter { $0.status == .pendiente }
        let recentPhotos = dataManager.getMedia(for: project.id).count

        var text = """
        *Reporte Semanal*
        *\(project.name)*

        Cliente: \(project.clientName)
        Progreso: \(progress)% (\(done.count)/\(tasks.count) tareas)

        *Tareas completadas esta semana:*

        """

        for task in done.prefix(5) {
            text += "  ✅ \(task.title)\n"
        }

        text += "\n*En proceso:*\n"
        for task in inProgress {
            text += "  🔄 \(task.title)\n"
        }

        if !pendingMissing.isEmpty {
            text += "\n*Faltantes pendientes (\(pendingMissing.count)):*\n"
            for item in pendingMissing {
                text += "  ⚠️ \(item.name) x\(item.qty)\n"
            }
        }

        text += "\n*Evidencia reciente:* \(recentPhotos) fotos\n"
        text += "\n---\n_Generado por PaisajistaOS_"

        let phone = project.clientPhone?.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "") ?? ""

        if let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://wa.me/\(phone)?text=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ReportPreview: View {
    let project: Project
    let dataManager: DataManager

    var progress: Double {
        dataManager.getProjectProgress(projectId: project.id)
    }

    var tasks: [ProjectTask] {
        dataManager.getTasks(for: project.id)
    }

    var missingItems: [MissingItem] {
        dataManager.getMissingItems(for: project.id)
    }

    var staff: [ProjectStaff] {
        dataManager.getStaff(for: project.id)
    }

    var media: [LogMedia] {
        dataManager.getMedia(for: project.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(project.name)
                        .font(.title3.bold())
                    Spacer()
                    StatusBadge(text: project.status.label, color: project.status == .activo ? .green : .orange)
                }
                Text("Reporte semanal - \(Date(), style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)

            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Progreso general")
                        .font(.headline)
                }

                HStack {
                    ProgressView(value: progress)
                        .tint(.green)
                    Text("\(Int(progress * 100))%")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                }

                Text("\(tasks.filter { $0.status == .hecho }.count) de \(tasks.count) tareas completadas")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)

            // Tasks Breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Desglose de tareas")
                    .font(.headline)

                HStack(spacing: 12) {
                    StatBox(value: "\(tasks.filter { $0.status == .pendiente }.count)", label: "Pendientes", color: .gray)
                    StatBox(value: "\(tasks.filter { $0.status == .enProceso }.count)", label: "En proceso", color: .blue)
                    StatBox(value: "\(tasks.filter { $0.status == .hecho }.count)", label: "Completadas", color: .green)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)

            // Missing Items
            if !missingItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "shippingbox.fill")
                            .foregroundColor(.orange)
                        Text("Faltantes (\(missingItems.count))")
                            .font(.headline)
                    }

                    ForEach(missingItems) { item in
                        HStack {
                            Text(item.name)
                            Text("x\(item.qty)")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(item.status.label)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(item.status == .pendiente ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                                .foregroundColor(item.status == .pendiente ? .red : .green)
                                .cornerRadius(4)
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }

            // Staff
            VStack(alignment: .leading, spacing: 8) {
                Text("Equipo asignado")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(staff, id: \.id) { staffMember in
                            if let user = dataManager.getUser(by: staffMember.userId) {
                                HStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Text(user.initials)
                                                .font(.caption2.bold())
                                                .foregroundColor(.green)
                                        )
                                    Text(user.name)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)

            // Evidence Count
            VStack(alignment: .leading, spacing: 8) {
                Text("Evidencia reciente (\(media.count) fotos)")
                    .font(.headline)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(media.prefix(4)) { _ in
                        ZStack {
                            LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)

            // Budget
            if let cost = project.estimatedCost {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Presupuesto")
                        .font(.headline)
                    Text(formatCOP(cost))
                        .font(.title2.bold())
                    Text("Costo estimado del proyecto")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack {
            Text(value)
                .font(.title.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        ReportsView()
            .environmentObject(DataManager())
    }
}
