import SwiftUI
import AmneziaCore

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
