import SwiftUI

struct NewMissingItemView: View {
    let projectId: String
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var category: MissingItemCategory = .planta
    @State private var qty = ""
    @State private var priority: Priority = .media
    @State private var neededBy = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @State private var supplier = ""

    var isValid: Bool {
        !name.isEmpty && !qty.isEmpty && Int(qty) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    Picker("Categoría", selection: $category) {
                        ForEach(MissingItemCategory.allCases, id: \.self) { cat in
                            Label(cat.label, systemImage: cat.icon).tag(cat)
                        }
                    }

                    TextField("Nombre", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section("Cantidad y Prioridad") {
                    TextField("Cantidad", text: $qty)
                        .keyboardType(.numberPad)

                    Picker("Prioridad", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.label).tag(p)
                        }
                    }

                    DatePicker("Fecha requerida", selection: $neededBy, displayedComponents: .date)
                }

                Section("Proveedor (Opcional)") {
                    TextField("Nombre del proveedor", text: $supplier)
                }
            }
            .navigationTitle("Nuevo Faltante")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agregar") {
                        createItem()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    func createItem() {
        let item = MissingItem(
            id: UUID().uuidString,
            projectId: projectId,
            category: category,
            name: name,
            qty: Int(qty) ?? 1,
            priority: priority,
            neededBy: neededBy,
            status: .pendiente,
            supplier: supplier.isEmpty ? nil : supplier
        )

        dataManager.addMissingItem(item)
        dismiss()
    }
}

#Preview {
    NewMissingItemView(projectId: "p1")
        .environmentObject(DataManager())
}
