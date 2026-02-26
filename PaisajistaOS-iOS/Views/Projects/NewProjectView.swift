import SwiftUI

struct NewProjectView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var clientName = ""
    @State private var clientPhone = ""
    @State private var location = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
    @State private var estimatedCost = ""
    @State private var description = ""

    var isValid: Bool {
        !name.isEmpty && !clientName.isEmpty && !location.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Información del Proyecto") {
                    TextField("Nombre del proyecto", text: $name)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Cliente") {
                    TextField("Nombre del cliente", text: $clientName)
                    TextField("Teléfono", text: $clientPhone)
                        .keyboardType(.phonePad)
                }

                Section("Ubicación") {
                    TextField("Dirección o referencia", text: $location)
                }

                Section("Fechas") {
                    DatePicker("Fecha de inicio", selection: $startDate, displayedComponents: .date)
                    DatePicker("Fecha de entrega", selection: $endDate, displayedComponents: .date)
                }

                Section("Presupuesto") {
                    TextField("Costo estimado (COP)", text: $estimatedCost)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Nuevo Proyecto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        createProject()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    func createProject() {
        let project = Project(
            id: UUID().uuidString,
            name: name,
            clientName: clientName,
            clientPhone: clientPhone.isEmpty ? nil : clientPhone,
            locationText: location,
            status: .activo,
            startDate: startDate,
            endDate: endDate,
            estimatedCost: Double(estimatedCost),
            description: description.isEmpty ? nil : description,
            createdAt: Date()
        )

        dataManager.addProject(project)
        dismiss()
    }
}

#Preview {
    NewProjectView()
        .environmentObject(DataManager())
}
