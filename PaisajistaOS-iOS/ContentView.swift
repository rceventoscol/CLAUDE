import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
                .tag(0)

            ProjectsListView()
                .tabItem {
                    Label("Proyectos", systemImage: "folder")
                }
                .tag(1)

            EmployeesView()
                .tabItem {
                    Label("Equipo", systemImage: "person.3")
                }
                .tag(2)

            FaltantesView()
                .tabItem {
                    Label("Faltantes", systemImage: "shippingbox")
                }
                .tag(3)

            MoreView()
                .tabItem {
                    Label("Más", systemImage: "ellipsis")
                }
                .tag(4)
        }
        .tint(Color("Primary"))
    }
}

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    PurchaseOrdersView()
                } label: {
                    Label("Órdenes de Compra", systemImage: "cart")
                }

                NavigationLink {
                    BitacoraView()
                } label: {
                    Label("Bitácora Visual", systemImage: "camera")
                }

                NavigationLink {
                    ReportsView()
                } label: {
                    Label("Reportes", systemImage: "doc.text")
                }
            }
            .navigationTitle("Más opciones")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
}
