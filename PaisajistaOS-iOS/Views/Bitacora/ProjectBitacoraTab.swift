import SwiftUI
import PhotosUI

struct ProjectBitacoraTab: View {
    let project: Project
    @EnvironmentObject var dataManager: DataManager
    @State private var showCamera = false
    @State private var showNewMedia = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Add Photo Button
                Button {
                    showNewMedia = true
                } label: {
                    Label("Subir Evidencia", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Media Timeline
                let media = dataManager.getMedia(for: project.id)

                if media.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No hay evidencia visual")
                            .foregroundColor(.secondary)
                        Button("Subir la primera foto") {
                            showNewMedia = true
                        }
                        .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ForEach(media) { item in
                        MediaCard(media: item, dataManager: dataManager)
                    }
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showNewMedia) {
            NewMediaView(projectId: project.id)
        }
    }
}

struct MediaCard: View {
    let media: LogMedia
    let dataManager: DataManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder (in real app would show actual image)
            ZStack {
                LinearGradient(
                    colors: [.green.opacity(0.3), .green.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .frame(height: 150)
            .cornerRadius(12)

            Text(media.caption)
                .font(.subheadline.bold())

            HStack {
                Text(media.createdAt, style: .date)
                Text("·")
                if let user = dataManager.getUser(by: media.createdBy) {
                    Text(user.name)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)

            // Tags
            FlowLayout(spacing: 4) {
                ForEach(media.tags, id: \.self) { tag in
                    Text(tag.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tagColor(tag).opacity(0.2))
                        .foregroundColor(tagColor(tag))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
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

// Simple FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
                self.size.width = max(self.size.width, currentX)
            }

            self.size.height = currentY + lineHeight
        }
    }
}

#Preview {
    ProjectBitacoraTab(project: DataManager().projects[0])
        .environmentObject(DataManager())
}
