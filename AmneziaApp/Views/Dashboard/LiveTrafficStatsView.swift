import SwiftUI
import AmneziaCore

public struct LiveTrafficStatsView: View {
    @ObservedObject var appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    private var stats: ConnectionStatistics {
        appState.connectionStats
    }

    public var body: some View {
        if appState.providesTrafficStats {
            HStack(spacing: 12) {
                // Download Card
                GlassCard {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))

                            Text("DOWNLOAD")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1)
                                .foregroundColor(.secondary)

                            Spacer()
                        }

                        Text(appState.connectionState.isConnected ? stats.formattedDownSpeed : "0 B/s")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Total: \(stats.formattedBytesIn)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }

                // Upload Card
                GlassCard {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))

                            Text("UPLOAD")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1)
                                .foregroundColor(.secondary)

                            Spacer()
                        }

                        Text(appState.connectionState.isConnected ? stats.formattedUpSpeed : "0 B/s")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Total: \(stats.formattedBytesOut)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
