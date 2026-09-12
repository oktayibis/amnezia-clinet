import SwiftUI
import PhotosUI
import Vision
import AmneziaCore

public struct QrPhotoPickerView: View {
    @ObservedObject var appState: AppState
    let onCompleted: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: PhotosPickerItem?
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?

    public init(appState: AppState, onCompleted: @escaping () -> Void) {
        self.appState = appState
        self.onCompleted = onCompleted
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "photo.badge.magnifyingglass")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                        .padding(.top, 40)

                    Text("Select QR Code Photo")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Pick an image or screenshot from your library containing a VPN configuration QR code.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Open Photo Library")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .padding(.top, 16)

                    if isProcessing {
                        ProgressView("Analyzing image...")
                            .tint(.white)
                            .foregroundColor(.white)
                            .padding(.top, 16)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Import from Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    guard let newItem else { return }
                    await processPickedPhoto(newItem)
                }
            }
            .alert("QR Detection", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                if let msg = errorMessage { Text(msg) }
            }
        }
    }

    private func processPickedPhoto(_ item: PhotosPickerItem) async {
        isProcessing = true
        defer { isProcessing = false }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else {
            errorMessage = "Failed to load selected image"
            return
        }

        let request = VNDetectBarcodesRequest { request, error in
            guard error == nil,
                  let results = request.results as? [VNBarcodeObservation] else {
                errorMessage = "No barcode found in image"
                return
            }

            for barcode in results where barcode.symbology == .qr {
                if let payload = barcode.payloadStringValue {
                    let assembler = QrCodeChunkAssembler()
                    let result = assembler.processScannedCode(payload)
                    switch result {
                    case .single(let profile), .completed(let profile):
                        DispatchQueue.main.async {
                            HapticFeedback.notification(type: .success)
                            appState.addProfile(profile)
                            dismiss()
                            onCompleted()
                        }
                        return
                    case .chunkProgress:
                        DispatchQueue.main.async {
                            errorMessage = "This image is part of a multi-chunk QR code. Please scan all chunks in order using the camera."
                        }
                        return
                    case .invalid(let msg):
                        DispatchQueue.main.async {
                            errorMessage = msg
                        }
                        return
                    }
                }
            }

            DispatchQueue.main.async {
                errorMessage = "Could not find a valid VPN configuration QR code in the photo"
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}
