import SwiftUI
import AVFoundation
import AmneziaCore

public struct QrScannerView: View {
    @ObservedObject var appState: AppState
    let onCompleted: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var chunkProgressText: String?
    @State private var isTorchOn: Bool = false
    @State private var assembler = QrCodeChunkAssembler()
    @State private var errorMessage: String?

    public init(appState: AppState, onCompleted: @escaping () -> Void) {
        self.appState = appState
        self.onCompleted = onCompleted
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                #if targetEnvironment(simulator)
                simulatorPlaceholder
                #else
                CameraScannerView(isTorchOn: isTorchOn) { scannedString in
                    handleScannedCode(scannedString)
                }
                .ignoresSafeArea()
                #endif

                // Viewfinder Overlay
                viewfinderOverlay

                // Multi-chunk HUD
                if let progress = chunkProgressText {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text(progress)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.85))
                        .cornerRadius(24)
                        .padding(.bottom, 60)
                    }
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { isTorchOn.toggle() }) {
                        Image(systemName: isTorchOn ? "bolt.fill" : "bolt.slash.fill")
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("QR Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                if let msg = errorMessage { Text(msg) }
            }
        }
    }

    private var viewfinderOverlay: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: 260, height: 260)

                // Corner accents
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: 260, height: 260)
            }

            Text("Align QR code within frame")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 24)

            Spacer()
        }
    }

    private var simulatorPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Camera unavailable in Simulator")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Button("Simulate QR Scan (Sample AWG)") {
                simulateSampleAwgScan()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.green)
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .padding()
    }

    private func handleScannedCode(_ text: String) {
        let result = assembler.processScannedCode(text)
        switch result {
        case .single(let profile), .completed(let profile):
            HapticFeedback.notification(type: .success)
            appState.addProfile(profile)
            dismiss()
            onCompleted()
        case .chunkProgress(let received, let total):
            HapticFeedback.selection()
            chunkProgressText = "Scanned \(received) of \(total) QR codes. Point at next QR."
        case .invalid(let msg):
            errorMessage = msg
        }
    }

    #if targetEnvironment(simulator) || DEBUG
    private func simulateSampleAwgScan() {
        let sample = """
        [Interface]
        Address = 10.8.0.2/32
        PrivateKey = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=
        DNS = 1.1.1.1
        Jc = 4
        Jmin = 40
        Jmax = 70
        S1 = 15
        S2 = 30
        H1 = 1
        H2 = 2
        H3 = 3
        H4 = 4

        [Peer]
        PublicKey = bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=
        Endpoint = 198.51.100.1:51820
        AllowedIPs = 0.0.0.0/0
        """
        handleScannedCode(sample)
    }
    #endif
}

// MARK: - UIKit Camera View Wrapper

#if canImport(UIKit)
private struct CameraScannerView: UIViewControllerRepresentable {
    let isTorchOn: Bool
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        uiViewController.setTorch(isTorchOn)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onCodeScanned: (String) -> Void
        private var hasScanned = false

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard !hasScanned,
                  let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let stringValue = metadataObject.stringValue else { return }

            hasScanned = true
            DispatchQueue.main.async {
                self.onCodeScanned(stringValue)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.hasScanned = false
                }
            }
        }
    }
}

private class ScannerViewController: UIViewController {
    var delegate: AVCaptureMetadataOutputObjectsDelegate?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    func setTorch(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              session.canAddInput(videoInput) else { return }

        session.addInput(videoInput)
        let metadataOutput = AVCaptureMetadataOutput()

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        self.previewLayer = preview
        self.captureSession = session

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
}
#endif
