import SwiftUI

public struct PrivacyNoticeView: View {
    @AppStorage("awg_privacy_notice_accepted") private var isPrivacyNoticeAccepted: Bool = false
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: "hand.raised.shield.fill")
                            .font(.system(size: 54))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, 24)

                        Text("Your Privacy Comes First")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("AWG Connect is an independent, open-source client designed with strict privacy standards.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)

                        VStack(spacing: 16) {
                            privacyBullet(
                                icon: "eye.slash.fill",
                                title: "Zero Data Collection",
                                description: "We do not track, log, or store your browsing history, DNS queries, or device information."
                            )

                            privacyBullet(
                                icon: "internaldrive.fill",
                                title: "On-Device Storage",
                                description: "All server configurations, cryptographic keys, and profiles remain strictly on your device."
                            )

                            privacyBullet(
                                icon: "arrow.triangle.swap",
                                title: "Direct Connection",
                                description: "Your network traffic routes directly between your device and your configured VPN endpoint without intermediary proxies."
                            )
                        }
                        .padding(.horizontal, 8)

                        Link(destination: URL(string: "https://github.com/oktayibis/amnezia-clinet/blob/main/PRIVACY.md")!) {
                            HStack {
                                Text("Read Full Privacy Policy")
                                    .font(.system(size: 13, weight: .semibold))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.green)
                        }
                        .padding(.top, 8)

                        Button(action: {
                            isPrivacyNoticeAccepted = true
                            dismiss()
                        }) {
                            Text("Agree & Continue")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [.green, Color(red: 0.1, green: 0.8, blue: 0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Privacy Notice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isPrivacyNoticeAccepted {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(!isPrivacyNoticeAccepted)
    }

    private func privacyBullet(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.green)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
