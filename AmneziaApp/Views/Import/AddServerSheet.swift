import SwiftUI
import UniformTypeIdentifiers
import AmneziaCore

public struct AddServerSheet: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var activeSheet: ActiveSheet?
    @State private var isDocumentPickerPresented = false

    enum ActiveSheet: Identifiable {
        case qrScanner
        case photoPicker
        case manualInput

        var id: String {
            switch self {
            case .qrScanner: return "qrScanner"
            case .photoPicker: return "photoPicker"
            case .manualInput: return "manualInput"
            }
        }
    }

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("Choose how you want to import your Amnezia or WireGuard configuration.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    VStack(spacing: 14) {
                        // 1. Scan QR Code
                        actionCard(
                            icon: "qrcode.viewfinder",
                            iconColor: .purple,
                            title: "Scan QR Code",
                            subtitle: "Scan a connection QR code with camera"
                        ) {
                            activeSheet = .qrScanner
                        }

                        // 2. Import from Photos
                        actionCard(
                            icon: "photo.on.rectangle",
                            iconColor: .blue,
                            title: "Import from Photos",
                            subtitle: "Pick a saved QR code screenshot or photo"
                        ) {
                            activeSheet = .photoPicker
                        }

                        // 3. Paste URL or Config
                        actionCard(
                            icon: "link",
                            iconColor: .green,
                            title: "Connection URL / Text",
                            subtitle: "Paste vpn:// URL or .conf configuration"
                        ) {
                            activeSheet = .manualInput
                        }

                        // 4. Import from File
                        actionCard(
                            icon: "doc.badge.plus",
                            iconColor: .orange,
                            title: "Import from File",
                            subtitle: "Select a .conf, .json, or .vpn file"
                        ) {
                            isDocumentPickerPresented = true
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 12)
            }
            .navigationTitle("Add Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .qrScanner:
                    QrScannerView(appState: appState) {
                        dismiss()
                    }
                case .photoPicker:
                    QrPhotoPickerView(appState: appState) {
                        dismiss()
                    }
                case .manualInput:
                    ManualUrlInputView(appState: appState) {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $isDocumentPickerPresented,
                allowedContentTypes: [.plainText, .json, UTType(filenameExtension: "conf") ?? .plainText, UTType(filenameExtension: "vpn") ?? .plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let fileUrl = urls.first else { return }
                    let didAccess = fileUrl.startAccessingSecurityScopedResource()
                    defer {
                        if didAccess { fileUrl.stopAccessingSecurityScopedResource() }
                    }
                    do {
                        _ = try appState.importFromFile(url: fileUrl)
                        HapticFeedback.notification(type: .success)
                        dismiss()
                    } catch {
                        appState.errorMessage = error.localizedDescription
                        HapticFeedback.notification(type: .error)
                    }
                case .failure(let error):
                    appState.errorMessage = error.localizedDescription
                    HapticFeedback.notification(type: .error)
                }
            }
        }
    }

    private func actionCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            GlassCard {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.18))
                            .frame(width: 44, height: 44)

                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(iconColor)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)

                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
