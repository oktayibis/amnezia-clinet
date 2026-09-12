import SwiftUI

public struct MacPrivacyNoticeView: View {
    @AppStorage("awg_privacy_notice_accepted") private var isPrivacyNoticeAccepted: Bool = false
    var onDismiss: (() -> Void)? = nil

    public init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.raised.shield.fill")
                .font(.system(size: 44))
                .foregroundColor(.green)
                .padding(.top, 12)

            Text("Privacy & Transparency")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text("AWG Connect is an open-source, client-only VPN manager.\nWe respect your digital sovereignty:")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                bulletRow(
                    icon: "eye.slash.fill",
                    title: "Zero Logging & Telemetry",
                    desc: "No analytics, no device identifiers, no browsing logs."
                )

                bulletRow(
                    icon: "lock.fill",
                    title: "Local Secret Storage",
                    desc: "Server keys, endpoints, and configs stay strictly on this Mac."
                )

                bulletRow(
                    icon: "network",
                    title: "Direct Peer Routing",
                    desc: "Encrypted packets route directly to your specified server with no third-party mediation."
                )
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)

            Link("Review Full Privacy Policy on GitHub", destination: URL(string: "https://github.com/oktayibis/amnezia-clinet/blob/main/PRIVACY.md")!)
                .font(.system(size: 11))
                .foregroundColor(.green)

            Button("I Understand & Agree") {
                isPrivacyNoticeAccepted = true
                onDismiss?()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.large)
            .padding(.bottom, 12)
        }
        .padding(24)
        .frame(width: 460)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func bulletRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.green)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
    }
}
