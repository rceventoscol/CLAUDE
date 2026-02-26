import Foundation

// MARK: - Enums

enum UserRole: String, Codable, CaseIterable {
    case admin = "admin"
    case supervisor = "supervisor"
    case empleado = "empleado"
    case cliente = "cliente"

    var label: String {
        switch self {
        case .admin: return "Administrador"
        case .supervisor: return "Supervisor"
        case .empleado: return "Empleado"
        case .cliente: return "Cliente"
        }
    }
}

enum ProjectStatus: String, Codable, CaseIterable {
    case activo = "activo"
    case enPausa = "en_pausa"
    case terminado = "terminado"

    var label: String {
        switch self {
        case .activo: return "Activo"
        case .enPausa: return "En Pausa"
        case .terminado: return "Terminado"
        }
    }
}

enum TaskStatus: String, Codable, CaseIterable {
    case pendiente = "pendiente"
    case enProceso = "en_proceso"
    case hecho = "hecho"

    var label: String {
        switch self {
        case .pendiente: return "Pendiente"
        case .enProceso: return "En Proceso"
        case .hecho: return "Hecho"
        }
    }
}

enum Priority: String, Codable, CaseIterable {
    case alta = "alta"
    case media = "media"
    case baja = "baja"

    var label: String {
        switch self {
        case .alta: return "Alta"
        case .media: return "Media"
        case .baja: return "Baja"
        }
    }
}

enum MissingItemCategory: String, Codable, CaseIterable {
    case matera = "matera"
    case insumo = "insumo"
    case planta = "planta"

    var label: String {
        switch self {
        case .matera: return "Matera"
        case .insumo: return "Insumo"
        case .planta: return "Planta"
        }
    }

    var icon: String {
        switch self {
        case .matera: return "leaf.circle"
        case .insumo: return "wrench.and.screwdriver"
        case .planta: return "leaf"
        }
    }
}

enum MissingItemStatus: String, Codable, CaseIterable {
    case pendiente = "pendiente"
    case enOrden = "en_orden"
    case comprado = "comprado"
    case entregado = "entregado"
    case instalado = "instalado"

    var label: String {
        switch self {
        case .pendiente: return "Pendiente"
        case .enOrden: return "En Orden"
        case .comprado: return "Comprado"
        case .entregado: return "Entregado"
        case .instalado: return "Instalado"
        }
    }
}

enum PurchaseOrderStatus: String, Codable, CaseIterable {
    case borrador = "borrador"
    case enviado = "enviado"
    case comprado = "comprado"
    case entregado = "entregado"

    var label: String {
        switch self {
        case .borrador: return "Borrador"
        case .enviado: return "Enviado"
        case .comprado: return "Comprado"
        case .entregado: return "Entregado"
        }
    }
}

enum MediaTag: String, Codable, CaseIterable {
    case riego = "riego"
    case poda = "poda"
    case plagas = "plagas"
    case instalacion = "instalación"
    case siembra = "siembra"
    case general = "general"
    case antes = "antes"
    case durante = "durante"
    case despues = "después"
}

// MARK: - Models

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var role: UserRole
    var phone: String
    var email: String
    var avatar: String?
    var available: Bool

    var initials: String {
        name.split(separator: " ").compactMap { $0.first }.map(String.init).joined()
    }
}

struct Project: Identifiable, Codable {
    let id: String
    var name: String
    var clientName: String
    var clientPhone: String?
    var locationText: String
    var status: ProjectStatus
    var startDate: Date
    var endDate: Date
    var estimatedCost: Double?
    var description: String?
    var createdAt: Date
}

struct ProjectTask: Identifiable, Codable {
    let id: String
    var projectId: String
    var title: String
    var taskDescription: String?
    var status: TaskStatus
    var priority: Priority
    var dueDate: Date
    var assignedUserId: String?
    var createdAt: Date
}

struct ProjectStaff: Identifiable, Codable {
    var id: String { "\(projectId)-\(userId)" }
    var projectId: String
    var userId: String
    var dateAssigned: Date
    var checkedIn: Bool
    var checkInTime: String?
}

struct MissingItem: Identifiable, Codable {
    let id: String
    var projectId: String
    var category: MissingItemCategory
    var name: String
    var qty: Int
    var priority: Priority
    var neededBy: Date
    var status: MissingItemStatus
    var supplier: String?
    var purchaseOrderId: String?
}

struct PurchaseOrder: Identifiable, Codable {
    let id: String
    var projectId: String
    var supplierName: String
    var status: PurchaseOrderStatus
    var totalEstimated: Double
    var createdAt: Date
    var receiptUrl: String?
}

struct PurchaseOrderItem: Identifiable, Codable {
    let id: String
    var purchaseOrderId: String
    var name: String
    var qty: Int
    var unitCostEst: Double
}

struct LogMedia: Identifiable, Codable {
    let id: String
    var projectId: String
    var imageData: Data?
    var caption: String
    var tags: [MediaTag]
    var createdBy: String
    var createdAt: Date
}
