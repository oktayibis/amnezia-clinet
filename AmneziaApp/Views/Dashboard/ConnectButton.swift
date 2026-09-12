import SwiftUI
import AmneziaCore

public struct ConnectButton: View {
    @ObservedObject var appState: AppState
    @State private var isPulsing = false
    @State private var rotationAngle: Double = 0

    public init(appState: AppState) {
        self.appState = appState
    }

    private var isConnected: Bool {
        appState.connectionState.isConnected
    }

    private var isConnecting: Bool {
        appState.connectionState.isConnecting
    }

    private var primaryColor: Color {
        if isConnected {
            return Color.green
        } else if isConnecting {
            return Color.orange
        } else {
            return Color(white: 0.28)
        }
    }

    public var body: some View {
        Button(action: {
            appState.toggleConnection()
        }) {
            ZStack {
                // Pulsing outer ripple when connected
                if isConnected {
                    Circle()
                        .stroke(Color.green.opacity(0.25), lineWidth: 2)
                        .frame(width: 220, height: 220)
                        .scaleEffect(isPulsing ? 1.15 : 0.95)
                        .opacity(isPulsing ? 0 : 0.8)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: false),
                            value: isPulsing
                        )

                    Circle()
                        .stroke(Color.green.opacity(0.15), lineWidth: 1)
                        .frame(width: 260, height: 260)
                        .scaleEffect(isPulsing ? 1.25 : 0.95)
                        .opacity(isPulsing ? 0 : 0.5)
                        .animation(
                            .easeInOut(duration: 2.0).delay(0.5).repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                }

                // Rotating gradient border when connecting
                if isConnecting {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.orange, .yellow, .clear, .orange],
                                center: .center
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 184, height: 184)
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                }

                // Outer ambient glow ring
                Circle()
                    .fill(primaryColor.opacity(isConnected ? 0.25 : 0.08))
                    .frame(width: 190, height: 190)
                    .blur(radius: isConnected ? 16 : 6)

                // Main Button Body
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isConnected ? [
                                Color(red: 0.08, green: 0.35, blue: 0.18),
                                Color(red: 0.04, green: 0.22, blue: 0.10)
                            ] : isConnecting ? [
                                Color(red: 0.35, green: 0.22, blue: 0.05),
                                Color(red: 0.22, green: 0.12, blue: 0.02)
                            ] : [
                                Color(white: 0.16),
                                Color(white: 0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 170, height: 170)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        primaryColor.opacity(0.8),
                                        primaryColor.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: primaryColor.opacity(isConnected ? 0.6 : 0.2),
                        radius: isConnected ? 24 : 8,
                        x: 0,
                        y: 0
                    )

                // Center Icon and State
                VStack(spacing: 8) {
                    Image(systemName: isConnected ? "shield.fill" : "power")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(isConnected ? .white : primaryColor)
                        .shadow(color: isConnected ? Color.green : .clear, radius: 10)

                    Text(isConnected ? "CONNECTED" : isConnecting ? "CONNECTING" : "CONNECT")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(isConnected ? .white : Color.white.opacity(0.85))
                }
            }
            .frame(width: 280, height: 280)
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            isPulsing = true
        }
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
