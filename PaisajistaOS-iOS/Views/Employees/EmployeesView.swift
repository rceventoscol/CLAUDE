import SwiftUI

struct EmployeesView: View {
    @EnvironmentObject var dataManager: DataManager

    var employees: [User] {
        dataManager.users.filter { $0.role != .cliente }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Who is Where Today
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Quién está dónde hoy")
                                .font(.headline)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(employees) { user in
                                let checkedIn = dataManager.checkedInStaff.first { $0.userId == user.id }
                                let project = checkedIn.flatMap { dataManager.getProject(by: $0.projectId) }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Circle()
                                            .fill(checkedIn != nil ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Text(user.initials)
                                                    .font(.caption.bold())
                                                    .foregroundColor(checkedIn != nil ? .green : .gray)
                                            )
                                        VStack(alignment: .leading) {
                                            Text(user.name)
                                                .font(.caption.bold())
                                                .lineLimit(1)
                                            if let project = project {
                                                Text(project.name)
                                                    .font(.caption2)
                                                    .foregroundColor(.green)
                                                    .lineLimit(1)
                                            } else {
                                                Text("Sin check-in")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(checkedIn != nil ? Color.green.opacity(0.1) : Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Employee List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Equipo completo")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(employees) { user in
                            EmployeeRow(user: user)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Empleados")
        }
    }
}

struct EmployeeRow: View {
    let user: User
    @EnvironmentObject var dataManager: DataManager

    var assignments: [Project] {
        dataManager.projectStaff
            .filter { $0.userId == user.id }
            .compactMap { dataManager.getProject(by: $0.projectId) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(user.initials)
                            .font(.headline)
                            .foregroundColor(.green)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(user.name)
                            .font(.headline)
                        RoleBadge(role: user.role)
                        if user.available {
                            Text("Disponible")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        } else {
                            Text("No disponible")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(4)
                        }
                    }
                    HStack {
                        Image(systemName: "phone")
                        Text(user.phone)
                        Text("·")
                        Image(systemName: "envelope")
                        Text(user.email)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            if !assignments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(assignments) { project in
                            Text(project.name)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct RoleBadge: View {
    let role: UserRole

    var color: Color {
        switch role {
        case .admin: return .purple
        case .supervisor: return .blue
        case .empleado: return .gray
        case .cliente: return .green
        }
    }

    var body: some View {
        Text(role.label)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

#Preview {
    EmployeesView()
        .environmentObject(DataManager())
}
