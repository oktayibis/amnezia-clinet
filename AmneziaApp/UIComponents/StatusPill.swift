import SwiftUI
import AmneziaCore

public struct StatusPill: View {
    let state: ConnectionState

    public init(state: ConnectionState) {
        self.state = state
    }

    private var color: Color {
        switch state {
        case .connected:
            return Color.green
        case .connecting, .reconnecting:
            return Color.orange
        case .disconnecting:
            return Color.yellow
        case .disconnected:
            return Color.secondary
        case .error:
            return Color.red
        }
    }

    public var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.8), radius: state.isConnected ? 4 : 0)

            Text(state.displayTitle)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.24), lineWidth: 1)
                )
        )
    }
}
