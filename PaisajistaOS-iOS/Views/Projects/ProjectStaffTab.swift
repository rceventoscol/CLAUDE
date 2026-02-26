import SwiftUI

struct ProjectStaffTab: View {
    let project: Project
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let staff = dataManager.getStaff(for: project.id)

                if staff.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.3")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No hay personal asignado")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ForEach(staff, id: \.id) { staffMember in
                        if let user = dataManager.getUser(by: staffMember.userId) {
                            StaffRow(user: user, staffMember: staffMember, projectId: project.id)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct StaffRow: View {
    let user: User
    let staffMember: ProjectStaff
    let projectId: String
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        HStack {
            Circle()
                .fill(staffMember.checkedIn ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.initials)
                        .font(.headline)
                        .foregroundColor(staffMember.checkedIn ? .green : .gray)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                HStack {
                    Text(user.role.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("·")
                        .foregroundColor(.secondary)
                    Text(user.phone)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if staffMember.checkedIn {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("En obra")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    if let time = staffMember.checkInTime {
                        Text(time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                        Text("Sin check-in")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Button {
                    dataManager.toggleCheckIn(projectId: projectId, userId: user.id)
                } label: {
                    Text(staffMember.checkedIn ? "Check-out" : "Check-in")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ProjectStaffTab(project: DataManager().projects[0])
        .environmentObject(DataManager())
}
