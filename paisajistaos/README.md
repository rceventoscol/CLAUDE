# PaisajistaOS

Centro operativo para paisajistas profesionales en Colombia. Gestiona proyectos, cuadrillas, materiales, evidencia visual y reportes para clientes.

## Requisitos

- Node.js 18+
- npm

## Instalación

```bash
cd paisajistaos
npm install
```

## Desarrollo

```bash
npm run dev
```

Abrir [http://localhost:3000](http://localhost:3000) en el navegador.

## Build de producción

```bash
npm run build
npm start
```

## Módulos (MVP)

1. **Dashboard** - KPIs: proyectos activos, tareas vencidas, faltantes urgentes, cuadrillas activas
2. **Proyectos** - Lista con filtros, detalle con tabs (Resumen, Tareas, Cuadrillas, Faltantes, Bitácora)
3. **Tareas** - Tablero Kanban (Pendiente / En proceso / Hecho) con prioridad y responsable
4. **Empleados** - Directorio + vista "Quién está dónde hoy" con check-in/out
5. **Faltantes** - Materiales/materas/plantas pendientes con conversión a orden de compra
6. **Órdenes de Compra** - Creación desde faltantes, estados, envío por WhatsApp
7. **Bitácora Visual** - Timeline de fotos con tags, filtros, comentarios
8. **Reportes** - Resumen semanal por proyecto, envío directo por WhatsApp

## Tech Stack

- **Frontend**: Next.js 16 + TypeScript + Tailwind CSS v4
- **Icons**: Lucide React
- **Estado**: React Context + useState (demo con datos seed)
- **Moneda**: COP (Peso Colombiano)
- **Idioma**: Español (es-CO)

## Estructura

```
src/
├── app/              # Rutas Next.js App Router
│   ├── page.tsx      # Dashboard
│   ├── proyectos/    # Proyectos + detalle [id]
│   ├── empleados/    # Empleados
│   ├── faltantes/    # Faltantes de materiales
│   ├── compras/      # Órdenes de compra
│   ├── bitacora/     # Bitácora visual
│   └── reportes/     # Reportes
├── components/       # Componentes reutilizables
│   ├── layout/       # Sidebar, Header, AppShell
│   └── ui/           # Card, Badge, Modal, ProgressBar, EmptyState
├── data/             # Datos seed de ejemplo
├── lib/              # Context, store, utilidades
└── types/            # Tipos TypeScript
```
