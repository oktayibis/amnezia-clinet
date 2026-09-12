import SwiftUI
import AmneziaCore

public struct SettingsView: View {
    @ObservedObject var appState: AppState
    @AppStorage("amnezia_kill_switch") private var isKillSwitchEnabled: Bool = false
    @AppStorage("amnezia_connect_on_launch") private var isConnectOnLaunch: Bool = false
    @AppStorage("amnezia_dns_provider") private var selectedDns: String = DnsProvider.serverDefault.rawValue
    @State private var isDnsSheetPresented = false

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                List {
                    // Security & Tunnel Options
                    Section(header: Text("TUNNEL & SECURITY").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)) {
                        Toggle(isOn: $isKillSwitchEnabled) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Kill Switch")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                Text("Block internet if VPN connection drops unexpectedly")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tint(.green)

                        Toggle(isOn: $isConnectOnLaunch) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Connect on Launch")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                Text("Automatically connect to active server when app opens")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tint(.green)
                    }
                    .listRowBackground(Color(white: 0.12))

                    // DNS Settings
                    Section(header: Text("DNS CONFIGURATION").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)) {
                        Button(action: { isDnsSheetPresented = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("DNS Resolver")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                    Text(selectedDns)
                                        .font(.system(size: 12))
                                        .foregroundColor(.green)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listRowBackground(Color(white: 0.12))

                    // Developer / Simulator Mode
                    #if DEBUG
                    Section(header: Text("DEVELOPER / DIAGNOSTICS").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)) {
                        Toggle(isOn: Binding(
                            get: { appState.isSimulatedTunnel },
                            set: { appState.setSimulatedTunnel($0) }
                        )) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Simulated Tunnel Engine")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                Text("Simulates connection flow and speed metrics (ideal for testing without Apple Developer entitlements)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tint(.yellow)
                    }
                    .listRowBackground(Color(white: 0.12))
                    #endif

                    // About & Open Source
                    Section(header: Text("ABOUT").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)) {
                        HStack {
                            Text("Version")
                                .foregroundColor(.white)
                            Spacer()
                            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
                            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                            Text("\(version) (\(build))")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Protocols")
                                .foregroundColor(.white)
                            Spacer()
                            Text("AmneziaWG, WireGuard")
                                .foregroundColor(.secondary)
                        }

                        Link(destination: URL(string: "https://github.com/oktayibis/amnezia-clinet/blob/main/PRIVACY.md")!) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Link(destination: URL(string: "https://github.com/oktayibis/amnezia-clinet")!) {
                            HStack {
                                Text("Source Code (GitHub)")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listRowBackground(Color(white: 0.12))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isDnsSheetPresented) {
                DnsSettingsView()
            }
        }
    }
}
