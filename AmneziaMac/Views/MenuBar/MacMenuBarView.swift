import SwiftUI
import AppKit
import AmneziaCore

public struct MacMenuBarView: View {
    @ObservedObject var appState: MacAppState
    var onOpenMainWindow: () -> Void

    public init(appState: MacAppState, onOpenMainWindow: @escaping () -> Void) {
        self.appState = appState
        self.onOpenMainWindow = onOpenMainWindow
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Header: Status & Latency
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(stateColor)
                        .frame(width: 8, height: 8)

                    Text(stateText)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(stateColor)
                }

                Spacer()

                if let ping = appState.pingLatencyMs, appState.selectedProfile != nil {
                    Text("\(ping) ms")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Active Server Selector
            if let active = appState.selectedProfile {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(active.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)

                        Text(active.endpointString)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(active.protocolType.badgeTitle)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            } else {
                Text("No server selected")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            // Connect / Disconnect Toggle Button
            Button(action: {
                appState.toggleConnection()
            }) {
                HStack {
                    Image(systemName: "power")
                    Text(appState.connectionState.isConnected ? "Disconnect" : "Connect")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(appState.connectionState.isConnected ? .red : .green)

            // Real-time Traffic Summary (if connected)
            if appState.connectionState.isConnected {
                HStack {
                    Label(appState.connectionStats.formattedDownSpeed, systemImage: "arrow.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.green)

                    Spacer()

                    Label(appState.connectionStats.formattedUpSpeed, systemImage: "arrow.up")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 4)
            }

            // Server Quick Switch Menu
            if appState.profiles.count > 1 {
                Divider()

                Menu("Switch Server (\(appState.profiles.count))") {
                    ForEach(appState.profiles) { profile in
                        Button(action: {
                            appState.selectProfile(profile)
                        }) {
                            HStack {
                                Text(profile.name)
                                if profile.id == appState.selectedProfile?.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }

            Divider()

            // Footer Actions
            HStack {
                Button("Open Dashboard") {
                    onOpenMainWindow()
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(.accentColor)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .frame(width: 280)
    }

    private var stateColor: Color {
        switch appState.connectionState {
        case .connected: return .green
        case .connecting, .reconnecting: return .orange
        case .disconnecting: return .red
        case .disconnected: return .gray
        case .error: return .red
        }
    }

    private var stateText: String {
        switch appState.connectionState {
        case .connected: return "CONNECTED"
        case .connecting: return "CONNECTING..."
        case .disconnecting: return "DISCONNECTING..."
        case .reconnecting: return "RECONNECTING..."
        case .disconnected: return "DISCONNECTED"
        case .error(let msg): return "ERROR: \(msg.uppercased())"
        }
    }
}
