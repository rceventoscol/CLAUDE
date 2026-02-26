# PaisajistaOS - iOS App

App nativa iOS para gestión de paisajismo profesional en Colombia. Diseñada para el App Store.

## Requisitos

- Mac con macOS 14.0 o superior
- Xcode 15.0 o superior
- iOS 17.0+ (target)

## Cómo abrir en Xcode

### Opción 1: Crear nuevo proyecto en Xcode (Recomendado)

1. Abre Xcode
2. File → New → Project
3. Selecciona "App" bajo iOS
4. Configuración:
   - Product Name: `PaisajistaOS`
   - Team: Tu cuenta de desarrollador
   - Organization Identifier: `co.paisajistaos` (o tu identifier)
   - Interface: SwiftUI
   - Language: Swift
5. Elige ubicación y crea el proyecto
6. **Borra los archivos predeterminados** (ContentView.swift, PaisajistaOSApp.swift)
7. Arrastra **TODOS los archivos de la carpeta `PaisajistaOS/`** a Xcode
8. Asegúrate de que "Copy items if needed" esté marcado
9. Build y Run!

### Opción 2: Clonar y configurar

```bash
git clone <tu-repo>
cd PaisajistaOS-iOS
```

Luego sigue los pasos de la Opción 1 para crear el proyecto Xcode y agregar los archivos.

## Estructura del proyecto

```
PaisajistaOS/
├── PaisajistaOSApp.swift      # Entry point
├── ContentView.swift           # Tab bar principal
├── Models/
│   └── Models.swift            # Todos los modelos de datos
├── Services/
│   └── DataManager.swift       # Gestión de estado y datos
├── Views/
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Projects/
│   │   ├── ProjectsListView.swift
│   │   ├── ProjectDetailView.swift
│   │   └── NewProjectView.swift
│   ├── Tasks/
│   │   ├── ProjectTasksTab.swift
│   │   └── NewTaskView.swift
│   ├── Employees/
│   │   └── EmployeesView.swift
│   ├── Faltantes/
│   │   ├── FaltantesView.swift
│   │   ├── ProjectFaltantesTab.swift
│   │   └── NewMissingItemView.swift
│   ├── Purchases/
│   │   └── PurchaseOrdersView.swift
│   ├── Bitacora/
│   │   ├── BitacoraView.swift
│   │   ├── ProjectBitacoraTab.swift
│   │   └── NewMediaView.swift
│   └── Reports/
│       └── ReportsView.swift
└── Assets.xcassets/
```

## Módulos

1. **Dashboard** - KPIs, proyectos en riesgo, quién está dónde
2. **Proyectos** - Lista, detalle con 5 tabs (Resumen, Tareas, Equipo, Faltantes, Fotos)
3. **Tareas** - Kanban board con estados Pendiente/En Proceso/Hecho
4. **Empleados** - Directorio y vista "quién está dónde hoy"
5. **Faltantes** - Materiales/plantas pendientes con estados
6. **Órdenes de Compra** - Crear desde faltantes, enviar por WhatsApp
7. **Bitácora Visual** - Timeline de fotos con tags
8. **Reportes** - Generar y enviar por WhatsApp al cliente

## Características

- 100% SwiftUI nativo
- iOS 17+ con las últimas APIs
- Integración WhatsApp para compartir reportes
- Selector de fotos nativo
- Moneda COP y español (es-CO)
- Datos de ejemplo incluidos (seed data)

## Para publicar en App Store

1. Crea una cuenta de Apple Developer ($99/año)
2. Configura tu App ID y provisioning profiles
3. Agrega un ícono de app (1024x1024px) en Assets
4. Configura Info.plist con permisos necesarios:
   - NSPhotoLibraryUsageDescription (para fotos)
   - NSCameraUsageDescription (si agregas cámara)
5. Archive y sube a App Store Connect
6. Completa la información de la app y envía a revisión

## Próximos pasos sugeridos

- [ ] Agregar persistencia real (Core Data o CloudKit)
- [ ] Implementar autenticación
- [ ] Agregar notificaciones push
- [ ] Modo offline con sincronización
- [ ] Mapas para ubicaciones de proyectos
