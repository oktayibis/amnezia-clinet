import SwiftUI

public enum DnsProvider: String, CaseIterable, Identifiable {
    case serverDefault = "Server Default"
    case cloudflare = "Cloudflare (1.1.1.1)"
    case adguard = "AdGuard (Blocks Ads & Trackers)"
    case quad9 = "Quad9 (Malware Protection)"
    case custom = "Custom DNS"

    public var id: String { rawValue }

    public var ips: [String] {
        switch self {
        case .serverDefault: return []
        case .cloudflare: return ["1.1.1.1", "1.0.0.1"]
        case .adguard: return ["94.140.14.14", "94.140.15.15"]
        case .quad9: return ["9.9.9.9", "149.112.112.112"]
        case .custom: return []
        }
    }
}

public struct DnsSettingsView: View {
    @AppStorage("amnezia_dns_provider") private var selectedProvider: String = DnsProvider.serverDefault.rawValue
    @AppStorage("amnezia_custom_dns") private var customDnsInput: String = ""
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                List {
                    Section(header: Text("DNS PROVIDERS").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)) {
                        ForEach(DnsProvider.allCases) { provider in
                            Button(action: {
                                selectedProvider = provider.rawValue
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(provider.rawValue)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.white)

                                        if !provider.ips.isEmpty {
                                            Text(provider.ips.joined(separator: ", "))
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()

                                    if selectedProvider == provider.rawValue {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                            }
                        }
                    }
                    .listRowBackground(Color(white: 0.12))

                    if selectedProvider == DnsProvider.custom.rawValue {
                        Section(header: Text("CUSTOM DNS IP ADDRESSES").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)) {
                            TextField("e.g. 1.1.1.1, 8.8.8.8", text: $customDnsInput)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color(white: 0.12))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("DNS Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
