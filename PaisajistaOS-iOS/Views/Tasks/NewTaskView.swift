import SwiftUI

struct NewTaskView: View {
    let projectId: String
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var priority: Priority = .media
    @State private var dueDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @State private var assignedUserId: String? = nil

    var isValid: Bool {
        !title.isEmpty
    }

    var availableUsers: [User] {
        dataManager.users.filter { $0.role != .cliente }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tarea") {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Detalles") {
                    Picker("Prioridad", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.label).tag(priority)
                        }
                    }

                    DatePicker("Fecha límite", selection: $dueDate, displayedComponents: .date)
                }

                Section("Asignar a") {
                    Picker("Responsable", selection: $assignedUserId) {
                        Text("Sin asignar").tag(nil as String?)
                        ForEach(availableUsers) { user in
                            Text(user.name).tag(user.id as String?)
                        }
                    }
                }
            }
            .navigationTitle("Nueva Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        createTask()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    func createTask() {
        let task = ProjectTask(
            id: UUID().uuidString,
            projectId: projectId,
            title: title,
            taskDescription: description.isEmpty ? nil : description,
            status: .pendiente,
            priority: priority,
            dueDate: dueDate,
            assignedUserId: assignedUserId,
            createdAt: Date()
        )

        dataManager.addTask(task)
        dismiss()
    }
}

#Preview {
    NewTaskView(projectId: "p1")
        .environmentObject(DataManager())
}
