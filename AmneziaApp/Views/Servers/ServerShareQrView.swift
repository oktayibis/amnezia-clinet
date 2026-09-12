import SwiftUI
import CoreImage.CIFilterBuiltins
import AmneziaCore
#if canImport(UIKit)
import UIKit
#endif

public struct ServerShareQrView: View {
    let profile: ServerProfile
    @Environment(\.dismiss) private var dismiss
    @State private var shareType: ShareType = .vpnUrl
    @State private var qrImage: Image?

    enum ShareType: String, CaseIterable {
        case vpnUrl = "vpn:// Link"
        case wireGuardConf = ".conf Text"
    }

    public init(profile: ServerProfile) {
        self.profile = profile
    }

    private var shareText: String {
        switch shareType {
        case .vpnUrl:
            return (try? AmneziaUrlDecoder.encodeToUrl(profile)) ?? ""
        case .wireGuardConf:
            return WgQuickConfigParser.serialize(profile)
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    Picker("Format", selection: $shareType) {
                        ForEach(ShareType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .onChange(of: shareType) { _ in
                        generateQr()
                    }

                    // QR Code Presentation
                    GlassCard {
                        VStack(spacing: 16) {
                            if let qrImage {
                                qrImage
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 240, height: 240)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(16)
                            } else {
                                ProgressView()
                                    .frame(width: 240, height: 240)
                            }

                            Text(profile.name)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Scan with AWG Connect or WireGuard to import")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: copyToClipboard) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Text")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(white: 0.2))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }

                        #if canImport(UIKit)
                        ShareLink(item: shareText) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(14)
                        }
                        #endif
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 16)
            }
            .navigationTitle("Share Config")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                generateQr()
            }
        }
    }

    private func generateQr() {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(Data(shareText.utf8), forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            #if canImport(UIKit)
            let uiImage = UIImage(cgImage: cgImage)
            qrImage = Image(uiImage: uiImage)
            #else
            qrImage = nil
            #endif
        }
    }

    private func copyToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = shareText
        HapticFeedback.notification(type: .success)
        #endif
    }
}
