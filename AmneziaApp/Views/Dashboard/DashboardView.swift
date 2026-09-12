import SwiftUI
import AmneziaCore

public struct DashboardView: View {
    @ObservedObject var appState: AppState
    @State private var showServerListSheet = false

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                backgroundLayer

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Status Pill
                        headerSection

                        // Clipboard Auto-Detection Banner
                        if let detected = appState.detectedClipboardUrl {
                            clipboardBanner(detected: detected)
                        }

                        // Centerpiece Connect Button
                        ConnectButton(appState: appState)
                            .padding(.vertical, 8)

                        // Uptime duration
                        if appState.connectionState.isConnected {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)

                                Text("Connected for \(appState.connectionStats.formattedDuration)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            .transition(.opacity.combined(with: .scale))
                        }

                        // Server Selector Card
                        ConnectionStatusCard(appState: appState) {
                            showServerListSheet = true
                        }

                        // Real-time Traffic Stats
                        LiveTrafficStatsView(appState: appState)

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("AMNEZIA")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.white.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        appState.isAddServerPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showServerListSheet) {
                ServerListView(appState: appState, isPresentedAsSheet: true)
            }
            .sheet(isPresented: $appState.isAddServerPresented) {
                AddServerSheet(appState: appState)
            }
            .alert("Amnezia", isPresented: Binding(
                get: { appState.errorMessage != nil },
                set: { if !$0 { appState.errorMessage = nil } }
            )) {
                if appState.errorMessage?.contains("Simulated Tunnel Engine") == true {
                    Button("Enable Simulation") {
                        appState.setSimulatedTunnel(true)
                        appState.errorMessage = nil
                        appState.toggleConnection()
                    }
                }
                Button("OK", role: .cancel) {
                    appState.errorMessage = nil
                }
            } message: {
                if let msg = appState.errorMessage {
                    Text(msg)
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack {
            StatusPill(state: appState.connectionState)
            Spacer()
            if appState.isSimulatedTunnel {
                Text("SIMULATED")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .foregroundColor(.yellow)
                    .clipShape(Capsule())
            }
        }
    }

    private func clipboardBanner(detected: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("Configuration in Clipboard")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)

                Text("Tap to import immediately")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Import") {
                do {
                    _ = try appState.importFromText(detected)
                    appState.detectedClipboardUrl = nil
                } catch {
                    appState.errorMessage = error.localizedDescription
                }
            }
            .font(.system(size: 12, weight: .bold))
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color.yellow)
            .foregroundColor(.black)
            .clipShape(Capsule())

            Button(action: {
                appState.detectedClipboardUrl = nil
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(white: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var backgroundLayer: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Subtle ambient radial glow
            RadialGradient(
                colors: [
                    appState.connectionState.isConnected ? Color.green.opacity(0.18) :
                    appState.connectionState.isConnecting ? Color.orange.opacity(0.18) :
                    Color.blue.opacity(0.06),
                Color.clear
                ],
                center: .top,
                startRadius: 20,
                endRadius: 450
            )
            .ignoresSafeArea()
        }
    }
}
