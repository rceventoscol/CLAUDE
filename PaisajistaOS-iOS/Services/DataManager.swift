import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var users: [User] = []
    @Published var projects: [Project] = []
    @Published var tasks: [ProjectTask] = []
    @Published var projectStaff: [ProjectStaff] = []
    @Published var missingItems: [MissingItem] = []
    @Published var purchaseOrders: [PurchaseOrder] = []
    @Published var purchaseOrderItems: [PurchaseOrderItem] = []
    @Published var logMedia: [LogMedia] = []

    init() {
        loadSeedData()
    }

    // MARK: - Computed Properties

    var activeProjects: [Project] {
        projects.filter { $0.status == .activo }
    }

    var overdueTasks: [ProjectTask] {
        tasks.filter { $0.status != .hecho && $0.dueDate < Date() }
    }

    var urgentMissingItems: [MissingItem] {
        missingItems.filter { $0.priority == .alta && $0.status == .pendiente }
    }

    var checkedInStaff: [ProjectStaff] {
        projectStaff.filter { $0.checkedIn }
    }

    // MARK: - Helper Methods

    func getProjectProgress(projectId: String) -> Double {
        let projectTasks = tasks.filter { $0.projectId == projectId }
        guard !projectTasks.isEmpty else { return 0 }
        let done = projectTasks.filter { $0.status == .hecho }.count
        return Double(done) / Double(projectTasks.count)
    }

    func getUser(by id: String) -> User? {
        users.first { $0.id == id }
    }

    func getProject(by id: String) -> Project? {
        projects.first { $0.id == id }
    }

    func getTasks(for projectId: String) -> [ProjectTask] {
        tasks.filter { $0.projectId == projectId }
    }

    func getMissingItems(for projectId: String) -> [MissingItem] {
        missingItems.filter { $0.projectId == projectId }
    }

    func getStaff(for projectId: String) -> [ProjectStaff] {
        projectStaff.filter { $0.projectId == projectId }
    }

    func getMedia(for projectId: String) -> [LogMedia] {
        logMedia.filter { $0.projectId == projectId }.sorted { $0.createdAt > $1.createdAt }
    }

    func getPurchaseOrders(for projectId: String) -> [PurchaseOrder] {
        purchaseOrders.filter { $0.projectId == projectId }
    }

    func isProjectAtRisk(_ projectId: String) -> Bool {
        let hasOverdue = tasks.contains { $0.projectId == projectId && $0.status != .hecho && $0.dueDate < Date() }
        let hasUrgentMissing = missingItems.contains { $0.projectId == projectId && $0.priority == .alta && $0.status == .pendiente }
        return hasOverdue || hasUrgentMissing
    }

    // MARK: - CRUD Operations

    func addProject(_ project: Project) {
        projects.append(project)
    }

    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        }
    }

    func addTask(_ task: ProjectTask) {
        tasks.append(task)
    }

    func updateTask(_ task: ProjectTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func moveTask(_ taskId: String, to status: TaskStatus) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].status = status
        }
    }

    func addMissingItem(_ item: MissingItem) {
        missingItems.append(item)
    }

    func updateMissingItem(_ item: MissingItem) {
        if let index = missingItems.firstIndex(where: { $0.id == item.id }) {
            missingItems[index] = item
        }
    }

    func toggleCheckIn(projectId: String, userId: String) {
        if let index = projectStaff.firstIndex(where: { $0.projectId == projectId && $0.userId == userId }) {
            projectStaff[index].checkedIn.toggle()
            if projectStaff[index].checkedIn {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                projectStaff[index].checkInTime = formatter.string(from: Date())
            } else {
                projectStaff[index].checkInTime = nil
            }
        }
    }

    func addLogMedia(_ media: LogMedia) {
        logMedia.append(media)
    }

    func createPurchaseOrder(from items: [MissingItem], projectId: String, supplierName: String) {
        let poId = UUID().uuidString
        let total = Double(items.reduce(0) { $0 + $1.qty }) * 50000 // Estimated

        let po = PurchaseOrder(
            id: poId,
            projectId: projectId,
            supplierName: supplierName,
            status: .borrador,
            totalEstimated: total,
            createdAt: Date()
        )
        purchaseOrders.append(po)

        for item in items {
            let poItem = PurchaseOrderItem(
                id: UUID().uuidString,
                purchaseOrderId: poId,
                name: item.name,
                qty: item.qty,
                unitCostEst: 50000
            )
            purchaseOrderItems.append(poItem)

            if let index = missingItems.firstIndex(where: { $0.id == item.id }) {
                missingItems[index].status = .enOrden
                missingItems[index].purchaseOrderId = poId
            }
        }
    }

    func advancePurchaseOrderStatus(_ poId: String) {
        guard let index = purchaseOrders.firstIndex(where: { $0.id == poId }) else { return }
        switch purchaseOrders[index].status {
        case .borrador: purchaseOrders[index].status = .enviado
        case .enviado: purchaseOrders[index].status = .comprado
        case .comprado: purchaseOrders[index].status = .entregado
        case .entregado: break
        }
    }

    // MARK: - Seed Data

    private func loadSeedData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Users
        users = [
            User(id: "u1", name: "Carlos Ramírez", role: .admin, phone: "+57 310 555 1234", email: "carlos@paisajistaos.co", available: true),
            User(id: "u2", name: "María López", role: .supervisor, phone: "+57 311 555 2345", email: "maria@paisajistaos.co", available: true),
            User(id: "u3", name: "Juan Pérez", role: .empleado, phone: "+57 312 555 3456", email: "juan@paisajistaos.co", available: true),
            User(id: "u4", name: "Andrés García", role: .empleado, phone: "+57 313 555 4567", email: "andres@paisajistaos.co", available: true),
            User(id: "u5", name: "Luisa Martínez", role: .empleado, phone: "+57 314 555 5678", email: "luisa@paisajistaos.co", available: false),
            User(id: "u6", name: "Pedro Castillo", role: .empleado, phone: "+57 315 555 6789", email: "pedro@paisajistaos.co", available: true),
            User(id: "u7", name: "Diana Rojas", role: .supervisor, phone: "+57 316 555 7890", email: "diana@paisajistaos.co", available: true),
        ]

        // Projects
        projects = [
            Project(id: "p1", name: "Jardín Residencia El Poblado", clientName: "Familia Gómez", clientPhone: "+57 300 111 2233", locationText: "Cra 43A #11Sur-30, El Poblado, Medellín", status: .activo, startDate: dateFormatter.date(from: "2026-01-15")!, endDate: dateFormatter.date(from: "2026-03-15")!, estimatedCost: 18500000, description: "Diseño e instalación de jardín frontal y posterior con sistema de riego automatizado.", createdAt: dateFormatter.date(from: "2026-01-10")!),
            Project(id: "p2", name: "Terraza Oficinas Chapinero", clientName: "Inversiones Bogotá SAS", clientPhone: "+57 300 222 3344", locationText: "Calle 72 #10-07, Chapinero, Bogotá", status: .activo, startDate: dateFormatter.date(from: "2026-01-20")!, endDate: dateFormatter.date(from: "2026-02-28")!, estimatedCost: 12000000, description: "Paisajismo para terraza corporativa piso 8.", createdAt: dateFormatter.date(from: "2026-01-18")!),
            Project(id: "p3", name: "Finca La Esperanza", clientName: "Don Hernando Mejía", clientPhone: "+57 300 333 4455", locationText: "Vereda El Retiro, Rionegro, Antioquia", status: .activo, startDate: dateFormatter.date(from: "2026-02-01")!, endDate: dateFormatter.date(from: "2026-12-31")!, estimatedCost: 36000000, description: "Mantenimiento mensual de jardines.", createdAt: dateFormatter.date(from: "2026-01-28")!),
            Project(id: "p4", name: "Centro Comercial Plaza Verde", clientName: "CC Plaza Verde", clientPhone: "+57 300 444 5566", locationText: "Av. El Dorado #68B-85, Bogotá", status: .enPausa, startDate: dateFormatter.date(from: "2025-11-01")!, endDate: dateFormatter.date(from: "2026-02-15")!, estimatedCost: 45000000, description: "Paisajismo interior. En pausa por ajustes.", createdAt: dateFormatter.date(from: "2025-10-20")!),
            Project(id: "p5", name: "Apartamento Rosales", clientName: "Sra. Patricia Duque", locationText: "Calle 73 #2-45, Rosales, Bogotá", status: .terminado, startDate: dateFormatter.date(from: "2025-10-01")!, endDate: dateFormatter.date(from: "2025-12-20")!, estimatedCost: 8500000, description: "Balcón con jardín vertical.", createdAt: dateFormatter.date(from: "2025-09-25")!),
        ]

        // Tasks
        tasks = [
            ProjectTask(id: "t1", projectId: "p1", title: "Preparar terreno jardín frontal", status: .hecho, priority: .alta, dueDate: dateFormatter.date(from: "2026-01-25")!, assignedUserId: "u3", createdAt: dateFormatter.date(from: "2026-01-15")!),
            ProjectTask(id: "t2", projectId: "p1", title: "Instalar sistema de riego zona A", status: .enProceso, priority: .alta, dueDate: dateFormatter.date(from: "2026-02-05")!, assignedUserId: "u4", createdAt: dateFormatter.date(from: "2026-01-15")!),
            ProjectTask(id: "t3", projectId: "p1", title: "Sembrar crotones y heliconias", status: .pendiente, priority: .media, dueDate: dateFormatter.date(from: "2026-02-10")!, assignedUserId: "u3", createdAt: dateFormatter.date(from: "2026-01-15")!),
            ProjectTask(id: "t4", projectId: "p1", title: "Instalar materas decorativas", status: .pendiente, priority: .media, dueDate: dateFormatter.date(from: "2026-02-15")!, createdAt: dateFormatter.date(from: "2026-01-15")!),
            ProjectTask(id: "t5", projectId: "p1", title: "Colocar piedra decorativa sendero", status: .pendiente, priority: .baja, dueDate: dateFormatter.date(from: "2026-02-20")!, createdAt: dateFormatter.date(from: "2026-01-15")!),
            ProjectTask(id: "t6", projectId: "p2", title: "Subir materas al piso 8", status: .hecho, priority: .alta, dueDate: dateFormatter.date(from: "2026-01-28")!, assignedUserId: "u4", createdAt: dateFormatter.date(from: "2026-01-20")!),
            ProjectTask(id: "t7", projectId: "p2", title: "Sembrar palmas areca", status: .enProceso, priority: .alta, dueDate: dateFormatter.date(from: "2026-02-03")!, assignedUserId: "u3", createdAt: dateFormatter.date(from: "2026-01-20")!),
            ProjectTask(id: "t8", projectId: "p2", title: "Instalar riego por goteo", status: .pendiente, priority: .media, dueDate: dateFormatter.date(from: "2026-02-10")!, createdAt: dateFormatter.date(from: "2026-01-20")!),
            ProjectTask(id: "t9", projectId: "p3", title: "Poda general febrero", status: .enProceso, priority: .alta, dueDate: dateFormatter.date(from: "2026-02-07")!, assignedUserId: "u4", createdAt: dateFormatter.date(from: "2026-02-01")!),
            ProjectTask(id: "t10", projectId: "p3", title: "Fumigación frutales", status: .pendiente, priority: .alta, dueDate: dateFormatter.date(from: "2026-02-10")!, assignedUserId: "u6", createdAt: dateFormatter.date(from: "2026-02-01")!),
        ]

        // Project Staff
        projectStaff = [
            ProjectStaff(projectId: "p1", userId: "u3", dateAssigned: dateFormatter.date(from: "2026-01-15")!, checkedIn: true, checkInTime: "07:30"),
            ProjectStaff(projectId: "p1", userId: "u4", dateAssigned: dateFormatter.date(from: "2026-01-15")!, checkedIn: true, checkInTime: "07:45"),
            ProjectStaff(projectId: "p2", userId: "u3", dateAssigned: dateFormatter.date(from: "2026-01-20")!, checkedIn: false),
            ProjectStaff(projectId: "p2", userId: "u6", dateAssigned: dateFormatter.date(from: "2026-01-20")!, checkedIn: true, checkInTime: "08:00"),
            ProjectStaff(projectId: "p3", userId: "u4", dateAssigned: dateFormatter.date(from: "2026-02-01")!, checkedIn: true, checkInTime: "06:30"),
        ]

        // Missing Items
        missingItems = [
            MissingItem(id: "m1", projectId: "p1", category: .planta, name: "Crotones grandes", qty: 15, priority: .alta, neededBy: dateFormatter.date(from: "2026-02-08")!, status: .pendiente, supplier: "Vivero El Jardín"),
            MissingItem(id: "m2", projectId: "p1", category: .planta, name: "Heliconias rojas", qty: 8, priority: .alta, neededBy: dateFormatter.date(from: "2026-02-08")!, status: .enOrden, supplier: "Vivero El Jardín", purchaseOrderId: "po1"),
            MissingItem(id: "m3", projectId: "p1", category: .insumo, name: "Sustrato orgánico (bultos)", qty: 20, priority: .media, neededBy: dateFormatter.date(from: "2026-02-10")!, status: .pendiente),
            MissingItem(id: "m4", projectId: "p1", category: .matera, name: "Materas fibrocemento 60cm", qty: 6, priority: .media, neededBy: dateFormatter.date(from: "2026-02-12")!, status: .pendiente, supplier: "Homecenter"),
            MissingItem(id: "m5", projectId: "p2", category: .planta, name: "Palmas Areca 1.5m", qty: 10, priority: .alta, neededBy: dateFormatter.date(from: "2026-02-03")!, status: .comprado, supplier: "Vivero Paraíso"),
            MissingItem(id: "m6", projectId: "p2", category: .insumo, name: "Kit riego por goteo", qty: 2, priority: .media, neededBy: dateFormatter.date(from: "2026-02-08")!, status: .pendiente),
            MissingItem(id: "m7", projectId: "p3", category: .insumo, name: "Fertilizante triple 15", qty: 5, priority: .alta, neededBy: dateFormatter.date(from: "2026-02-13")!, status: .pendiente),
        ]

        // Purchase Orders
        purchaseOrders = [
            PurchaseOrder(id: "po1", projectId: "p1", supplierName: "Vivero El Jardín", status: .enviado, totalEstimated: 960000, createdAt: dateFormatter.date(from: "2026-02-01")!),
            PurchaseOrder(id: "po2", projectId: "p2", supplierName: "Vivero Paraíso", status: .comprado, totalEstimated: 1500000, createdAt: dateFormatter.date(from: "2026-01-25")!),
        ]

        purchaseOrderItems = [
            PurchaseOrderItem(id: "poi1", purchaseOrderId: "po1", name: "Heliconias rojas", qty: 8, unitCostEst: 45000),
            PurchaseOrderItem(id: "poi2", purchaseOrderId: "po1", name: "Abono orgánico", qty: 5, unitCostEst: 72000),
            PurchaseOrderItem(id: "poi3", purchaseOrderId: "po2", name: "Palmas Areca 1.5m", qty: 10, unitCostEst: 120000),
        ]

        // Log Media
        logMedia = [
            LogMedia(id: "lm1", projectId: "p1", caption: "Terreno antes de iniciar - jardín frontal", tags: [.antes, .general], createdBy: "u2", createdAt: dateFormatter.date(from: "2026-01-15")!),
            LogMedia(id: "lm2", projectId: "p1", caption: "Preparación del terreno completada", tags: [.durante, .instalacion], createdBy: "u3", createdAt: dateFormatter.date(from: "2026-01-25")!),
            LogMedia(id: "lm3", projectId: "p1", caption: "Inicio instalación sistema de riego", tags: [.durante, .riego], createdBy: "u4", createdAt: dateFormatter.date(from: "2026-02-01")!),
            LogMedia(id: "lm4", projectId: "p2", caption: "Terraza antes del proyecto", tags: [.antes, .general], createdBy: "u2", createdAt: dateFormatter.date(from: "2026-01-20")!),
            LogMedia(id: "lm5", projectId: "p2", caption: "Materas instaladas en piso 8", tags: [.durante, .instalacion], createdBy: "u6", createdAt: dateFormatter.date(from: "2026-01-28")!),
            LogMedia(id: "lm6", projectId: "p3", caption: "Estado general finca - inicio febrero", tags: [.antes, .general], createdBy: "u7", createdAt: dateFormatter.date(from: "2026-02-01")!),
        ]
    }
}
