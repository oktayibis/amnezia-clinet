import SwiftUI
import AmneziaCore
#if canImport(UIKit)
import UIKit
#endif

public struct ManualUrlInputView: View {
    @ObservedObject var appState: AppState
    let onCompleted: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var inputText: String = ""
    @State private var errorMessage: String?

    public init(appState: AppState, onCompleted: @escaping () -> Void) {
        self.appState = appState
        self.onCompleted = onCompleted
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Paste a connection string (starts with vpn:// or awgconnect://) or a WireGuard / AmneziaWG configuration.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    // Text Editor
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(white: 0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )

                        TextEditor(text: $inputText)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .autocorrectionDisabled()
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            #endif

                        if inputText.isEmpty {
                            Text("vpn://... or [Interface]...")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(height: 220)
                    .padding(.horizontal, 20)

                    // Paste from Clipboard Button
                    HStack(spacing: 12) {
                        Button(action: pasteFromClipboard) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.clipboard")
                                Text("Paste from Clipboard")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(white: 0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        #if DEBUG
                        Button(action: insertSampleAwg) {
                            Text("Sample AWG")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        #endif

                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Import Button
                    Button(action: importConfig) {
                        Text("Import Configuration")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(inputText.isEmpty ? Color.gray.opacity(0.3) : Color.green)
                            .foregroundColor(inputText.isEmpty ? .secondary : .black)
                            .cornerRadius(16)
                    }
                    .disabled(inputText.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Manual Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("Import Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                if let msg = errorMessage { Text(msg) }
            }
        }
    }

    private func pasteFromClipboard() {
        #if canImport(UIKit)
        if let string = UIPasteboard.general.string {
            inputText = string
            HapticFeedback.selection()
        }
        #endif
    }

    #if DEBUG
    private func insertSampleAwg() {
        inputText = """
        [Interface]
        Address = 10.8.0.2/32
        PrivateKey = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=
        DNS = 1.1.1.1, 1.0.0.1
        MTU = 1360
        Jc = 4
        Jmin = 40
        Jmax = 70
        S1 = 15
        S2 = 30
        H1 = 12345678
        H2 = 87654321
        H3 = 11223344
        H4 = 44332211

        [Peer]
        PublicKey = bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=
        Endpoint = 198.51.100.1:51820
        AllowedIPs = 0.0.0.0/0
        PersistentKeepalive = 25
        """
    }
    #endif

    private func importConfig() {
        do {
            _ = try appState.importFromText(inputText)
            HapticFeedback.notification(type: .success)
            dismiss()
            onCompleted()
        } catch {
            errorMessage = error.localizedDescription
            HapticFeedback.notification(type: .error)
        }
    }
}
