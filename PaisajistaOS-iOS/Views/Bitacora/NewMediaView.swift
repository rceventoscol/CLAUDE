import SwiftUI
import PhotosUI

struct NewMediaView: View {
    let projectId: String
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    @State private var caption = ""
    @State private var selectedTags: Set<MediaTag> = [.durante, .general]
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var isValid: Bool {
        !caption.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Foto") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if selectedImageData != nil {
                            ZStack {
                                LinearGradient(
                                    colors: [.green.opacity(0.3), .green.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                VStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                    Text("Foto seleccionada")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                            }
                            .frame(height: 150)
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                Text("Seleccionar foto")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .onChange(of: selectedPhoto) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }

                Section("Descripción") {
                    TextField("¿Qué muestra esta foto?", text: $caption, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Tags") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(MediaTag.allCases, id: \.self) { tag in
                            Button {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            } label: {
                                Text(tag.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedTags.contains(tag) ? tagColor(tag) : tagColor(tag).opacity(0.2))
                                    .foregroundColor(selectedTags.contains(tag) ? .white : tagColor(tag))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Subir Evidencia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Subir") {
                        uploadMedia()
                    }
                    .disabled(!isValid)
                }
            }
        }
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

    func uploadMedia() {
        let media = LogMedia(
            id: UUID().uuidString,
            projectId: projectId,
            imageData: selectedImageData,
            caption: caption,
            tags: Array(selectedTags),
            createdBy: "u1", // Current user
            createdAt: Date()
        )

        dataManager.addLogMedia(media)
        dismiss()
    }
}

#Preview {
    NewMediaView(projectId: "p1")
        .environmentObject(DataManager())
}
