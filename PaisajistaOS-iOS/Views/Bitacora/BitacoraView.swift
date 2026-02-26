import SwiftUI

struct BitacoraView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedProject: String? = nil
    @State private var selectedTag: MediaTag? = nil

    var filteredMedia: [LogMedia] {
        var media = dataManager.logMedia.sorted { $0.createdAt > $1.createdAt }
        if let projectId = selectedProject {
            media = media.filter { $0.projectId == projectId }
        }
        if let tag = selectedTag {
            media = media.filter { $0.tags.contains(tag) }
        }
        return media
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filters
            VStack(spacing: 8) {
                // Project Filter
                Menu {
                    Button("Todos los proyectos") {
                        selectedProject = nil
                    }
                    ForEach(dataManager.projects) { project in
                        Button(project.name) {
                            selectedProject = project.id
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "folder")
                        Text(selectedProject.flatMap { dataManager.getProject(by: $0)?.name } ?? "Todos los proyectos")
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                }

                // Tag Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MediaTag.allCases, id: \.self) { tag in
                            Button {
                                selectedTag = selectedTag == tag ? nil : tag
                            } label: {
                                Text(tag.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedTag == tag ? tagColor(tag) : tagColor(tag).opacity(0.2))
                                    .foregroundColor(selectedTag == tag ? .white : tagColor(tag))
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            // Timeline
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredMedia) { media in
                        TimelineRow(media: media, dataManager: dataManager)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Bitácora Visual")
    }

    func tagColor(_ tag: MediaTag) -> Color {
        switch tag {
        case .riego: return .cyan
        case .poda: return .green
        case .plagas: return .red
        case .instalacion: return .purple
        case .siembra: return .green
        case .general: return .gray
        case .antes: return .orange
        case .durante: return .blue
        case .despues: return .green
        }
    }
}

struct TimelineRow: View {
    let media: LogMedia
    let dataManager: DataManager

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline Line
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2)
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Image Placeholder
                ZStack {
                    LinearGradient(
                        colors: [.green.opacity(0.3), .green.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .cornerRadius(10)

                Text(media.caption)
                    .font(.subheadline.bold())

                HStack {
                    Text(media.createdAt, style: .date)
                    if let project = dataManager.getProject(by: media.projectId) {
                        Text("·")
                        Text(project.name)
                            .foregroundColor(.green)
                    }
                    if let user = dataManager.getUser(by: media.createdBy) {
                        Text("·")
                        Text(user.name)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)

                // Tags
                HStack(spacing: 4) {
                    ForEach(media.tags, id: \.self) { tag in
                        Text(tag.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tagColor(tag).opacity(0.2))
                            .foregroundColor(tagColor(tag))
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding(.bottom, 16)
    }

    func tagColor(_ tag: MediaTag) -> Color {
        switch tag {
        case .riego: return .cyan
        case .poda: return .green
        case .plagas: return .red
        case .instalacion: return .purple
        case .siembra: return .green
        case .general: return .gray
        case .antes: return .orange
        case .durante: return .blue
        case .despues: return .green
        }
    }
}

#Preview {
    NavigationStack {
        BitacoraView()
            .environmentObject(DataManager())
    }
}
