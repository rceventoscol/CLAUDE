import SwiftUI

struct ProjectTasksTab: View {
    let project: Project
    @EnvironmentObject var dataManager: DataManager
    @State private var showNewTask = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Add Task Button
                Button {
                    showNewTask = true
                } label: {
                    Label("Nueva Tarea", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Kanban Columns
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    TaskColumn(
                        status: status,
                        tasks: dataManager.getTasks(for: project.id).filter { $0.status == status },
                        dataManager: dataManager
                    )
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showNewTask) {
            NewTaskView(projectId: project.id)
        }
    }
}

struct TaskColumn: View {
    let status: TaskStatus
    let tasks: [ProjectTask]
    let dataManager: DataManager

    var columnColor: Color {
        switch status {
        case .pendiente: return .gray
        case .enProceso: return .blue
        case .hecho: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(columnColor)
                    .frame(width: 8, height: 8)
                Text(status.label)
                    .font(.headline)
                Spacer()
                Text("\(tasks.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            if tasks.isEmpty {
                Text("Sin tareas")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(tasks) { task in
                    TaskCard(task: task, dataManager: dataManager)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct TaskCard: View {
    let task: ProjectTask
    @ObservedObject var dataManager: DataManager

    var isOverdue: Bool {
        task.status != .hecho && task.dueDate < Date()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.subheadline.bold())

            HStack {
                PriorityBadge(priority: task.priority)
                if isOverdue {
                    Text("Vencida")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }
                Spacer()
                Text(task.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let userId = task.assignedUserId,
               let user = dataManager.getUser(by: userId) {
                HStack {
                    Image(systemName: "person.circle")
                    Text(user.name)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            // Move Buttons
            HStack(spacing: 8) {
                if task.status != .pendiente {
                    Button {
                        let newStatus: TaskStatus = task.status == .hecho ? .enProceso : .pendiente
                        dataManager.moveTask(task.id, to: newStatus)
                    } label: {
                        Text("← Atrás")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if task.status != .hecho {
                    Button {
                        let newStatus: TaskStatus = task.status == .pendiente ? .enProceso : .hecho
                        dataManager.moveTask(task.id, to: newStatus)
                    } label: {
                        Text("Avanzar →")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct PriorityBadge: View {
    let priority: Priority

    var color: Color {
        switch priority {
        case .alta: return .red
        case .media: return .orange
        case .baja: return .blue
        }
    }

    var body: some View {
        Text(priority.label)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

#Preview {
    ProjectTasksTab(project: DataManager().projects[0])
        .environmentObject(DataManager())
}
