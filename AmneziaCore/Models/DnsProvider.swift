import Foundation

public enum DnsProvider: String, CaseIterable, Identifiable, Codable, Sendable {
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
