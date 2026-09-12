# AWG Connect (iOS & macOS)

A modern, high-performance, open-source native iOS and macOS client for **AmneziaWG** and **WireGuard**, built exclusively using **Swift**, **SwiftUI**, and Apple's **NetworkExtension** framework.

> [!NOTE]
> **Disclaimer**: AWG Connect is an independent, community-driven open-source client compatible with the AmneziaWG and WireGuard protocols. It is not affiliated with, endorsed by, or sponsored by Privacy Technologies or the official Amnezia VPN project.

Unlike multi-platform desktop ports, this client is designed from the ground up for Apple platforms:
- **Client-Focused**: Zero server provisioning or Docker installation bloat. Purely focused on lightning-fast, reliable VPN connectivity.
- **Apple Native Design**: Modern SwiftUI interface with frosted glass styling (`.ultraThinMaterial`), spring animations, tactile haptic feedback, and an ambient dark mode.
- **Full AmneziaWG (AWG) Obfuscation**: Deep support for Amnezia's custom WireGuard obfuscation headers and junk packet parameters (`Jc`, `Jmin`, `Jmax`, `S1`, `S2`, `S3`, `S4`, `H1`...`H4`, `I1`...`I5`).
- **Flexible Import Engine**: Import connections via QR code (camera or photo library), `vpn://` URLs, WireGuard/AmneziaWG `.conf` text, or configuration files.
- **Multi-Chunk QR Support**: Automatically assembles and decodes Amnezia's multi-part QR codes for large configurations (>850 bytes).
- **Privacy-Centric**: Zero analytics, zero data collection, zero telemetry. All secrets stay strictly on your local device.

---

## 📱 Features

### 1. Zero-Friction Dashboard
- **Interactive Power Button**: Large circular connect button with glowing ambient rings and state-adaptive animations.
- **Live Performance Metrics**: Real-time download & upload speeds, session data counters, and connection duration timer.
- **Server Health Card**: Displays active server, country flag, protocol badge, and endpoint.

### 2. Smart Connection Importer
- **Live Camera Scanner**: High-speed QR scanner with reticle viewfinder and torch control (iOS).
- **Photos QR Scanner**: Detects and imports QR codes directly from screenshots and photos using Apple's Vision framework (iOS).
- **Manual / Clipboard Import**: Direct, user-authorized import from clipboard or text configuration.
- **File Import**: Supports `.conf`, `.vpn`, and `.json` files via the iOS document picker.

### 3. Server Management & Sharing
- Organize multiple server configurations.
- View and inspect all cryptographic keys, endpoint details, and AWG obfuscation parameters.
- Re-export configurations to shareable QR codes or `vpn://` links.

### 4. Advanced Security
- **Kill Switch**: Blocks network traffic if the VPN connection unexpectedly drops.
- **Connect on Launch**: Automatically connects to the preferred server when the app starts.
- **Custom DNS Resolvers**: Switch between Server Default, Cloudflare (`1.1.1.1`), AdGuard DNS (built-in ad & tracker blocking), Quad9, or custom IP addresses.

---

## 🏗️ Architecture

```
amnezia-client/
├── project.yml                               # XcodeGen project definition
├── Package.swift                             # Swift Package Manager manifest
├── AmneziaCore/                              # Core protocol, parsing & storage logic
│   ├── Models/
│   │   ├── ServerProfile.swift               # Connection profile & metadata
│   │   ├── AwgParameters.swift               # AmneziaWG obfuscation fields
│   │   └── ConnectionState.swift             # Tunnel state & traffic statistics
│   ├── Parsers/
│   │   ├── AmneziaUrlDecoder.swift           # vpn:// base64url & JSON decoder
│   │   ├── WgQuickConfigParser.swift         # wg-quick & awg-quick .conf parser/serializer
│   │   ├── QrCodeChunkAssembler.swift        # Multi-chunk QR code reassembler
│   │   └── ZlibHelper.swift                  # Swift C-interop zlib inflate/deflate
│   ├── Storage/
│   │   └── ProfileStorage.swift              # AppGroup UserDefaults & profile storage
│   └── Tunnel/
│       ├── TunnelService.swift               # Tunnel abstraction & MockTunnelService
│       └── NetworkExtensionTunnelService.swift# Apple NETunnelProviderManager wrapper
├── AmneziaApp/                               # Native SwiftUI iOS Application
│   ├── App/
│   │   ├── AmneziaApp.swift                  # App entry point, TabView & deep links
│   │   └── AppState.swift                    # Observable application state
│   ├── UIComponents/
│   │   ├── GlassCard.swift                   # Frosted glass card containers
│   │   ├── StatusPill.swift                  # Connection state pill badge
│   │   └── HapticFeedback.swift              # Tactile haptic feedback wrappers
│   └── Views/
│       ├── Dashboard/                        # Connect button, status card, live stats
│       ├── Servers/                          # Server list, detail view, QR share
│       ├── Import/                           # Camera scanner, photo picker, manual input
│       └── Settings/                         # Kill switch, DNS selection, diagnostics
├── AmneziaTunnel/                            # Network Extension target
│   ├── PacketTunnelProvider.swift            # NEPacketTunnelProvider implementation
│   └── Info.plist
└── Tests/
    └── AmneziaCoreTests/                     # Comprehensive automated test suite
        ├── AmneziaUrlDecoderTests.swift
        ├── WgQuickConfigParserTests.swift
        ├── QrChunkAssemblerTests.swift
        ├── ZlibHelperTests.swift
        └── ProfileStorageTests.swift
```

---

## 🚀 Getting Started

### Requirements
- macOS 14.0+
- Xcode 15.0+ (iOS 16.0+ SDK)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Building the Project
1. Generate the `.xcodeproj` file:
   ```bash
   xcodegen generate
   ```

2. Open in Xcode:
   ```bash
   open AmneziaClient.xcodeproj
   ```

3. Build and run on the iOS Simulator or a connected iPhone:
   - Select the `AmneziaApp` scheme.
   - Choose your target device/simulator and press **Cmd + R**.

### Running Automated Tests
You can run tests directly from the terminal with Swift PM:
```bash
swift test
```
Or via `xcodebuild`:
```bash
xcodebuild -project AmneziaClient.xcodeproj -scheme AmneziaCoreTests -destination "platform=iOS Simulator,name=iPhone 17 Pro" test
```

---

## 🤖 Android Parity Roadmap

The architecture was intentionally designed with clean separation between the protocol core (`AmneziaCore`) and UI (`AmneziaApp`). 

The next phase will introduce the **Android** counterpart using:
- **Jetpack Compose** matching the dark glassmorphic design system.
- Shared models and parsers directly adaptable or portable to Kotlin.
- Android `VpnService` implementing AmneziaWG tunnel management.

---

## 📄 License

This project is licensed under the MIT License.
