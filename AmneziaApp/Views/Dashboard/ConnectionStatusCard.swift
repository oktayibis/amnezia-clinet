import SwiftUI
import AmneziaCore

public struct ConnectionStatusCard: View {
    @ObservedObject var appState: AppState
    let onSelectServer: () -> Void

    public init(appState: AppState, onSelectServer: @escaping () -> Void) {
        self.appState = appState
        self.onSelectServer = onSelectServer
    }

    public var body: some View {
        Button(action: onSelectServer) {
            GlassCard {
                HStack(spacing: 14) {
                    // Server Flag / Icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 48, height: 48)

                        Text(appState.selectedProfile?.flagEmoji ?? "🌐")
                            .font(.system(size: 26))
                    }

                    // Server Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appState.selectedProfile?.name ?? "No Server Selected")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        HStack(spacing: 8) {
                            if let profile = appState.selectedProfile {
                                Text(profile.protocolType.badgeTitle)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(profile.protocolType == .amneziaWg ? Color.purple.opacity(0.3) : Color.blue.opacity(0.3))
                                    )
                                    .foregroundColor(profile.protocolType == .amneziaWg ? .purple : .blue)

                                Text(profile.endpointString)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            } else {
                                Text("Tap to add a connection")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    // Ping Latency & Chevron
                    VStack(alignment: .trailing, spacing: 4) {
                        if let ping = appState.connectionStats.latencyMs ?? appState.selectedProfile?.pingMs {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(ping < 50 ? Color.green : ping < 120 ? Color.orange : Color.red)
                                    .frame(width: 6, height: 6)

                                Text("\(ping) ms")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
