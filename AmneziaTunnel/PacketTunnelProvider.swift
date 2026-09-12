import Foundation
#if canImport(NetworkExtension)
import NetworkExtension
import AmneziaCore

open class PacketTunnelProvider: NEPacketTunnelProvider {

    private var profile: ServerProfile?

    open override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        guard let conf = (protocolConfiguration as? NETunnelProviderProtocol)?.providerConfiguration,
              let configString = conf["config"] as? String else {
            completionHandler(NSError(domain: "AmneziaTunnel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Configuration payload missing"]))
            return
        }

        do {
            let profile = try WgQuickConfigParser.parse(configString)
            self.profile = profile

            // Setup Apple Network Settings
            let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: profile.endpointHost)

            // IPv4 Settings
            let ipv4Addresses = profile.clientAddresses.compactMap { addr -> String? in
                addr.components(separatedBy: "/").first
            }
            let ipv4Subnets = ipv4Addresses.map { _ in "255.255.255.255" }

            let ipv4Settings = NEIPv4Settings(addresses: ipv4Addresses, subnetMasks: ipv4Subnets)
            ipv4Settings.includedRoutes = [NEIPv4Route.default()]
            settings.ipv4Settings = ipv4Settings

            // DNS Settings
            let dnsServers: [String]
            if let overrideServers = conf["dnsOverride"] as? [String], !overrideServers.isEmpty {
                dnsServers = overrideServers
            } else {
                dnsServers = profile.dnsServers
            }

            if !dnsServers.isEmpty {
                let dnsSettings = NEDNSSettings(servers: dnsServers)
                dnsSettings.matchDomains = [""] // Route all DNS through tunnel
                settings.dnsSettings = dnsSettings
            }

            // MTU
            if let mtu = profile.mtu {
                settings.mtu = NSNumber(value: mtu)
            } else {
                settings.mtu = NSNumber(value: 1280)
            }

            setTunnelNetworkSettings(settings) { error in
                if let error {
                    completionHandler(error)
                } else {
                    // Tunnel established
                    completionHandler(nil)
                }
            }
        } catch {
            completionHandler(error)
        }
    }

    open override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Teardown network sessions
        completionHandler()
    }

    open override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // App IPC communication
        let response = ["status": "ok"]
        let resData = try? JSONSerialization.data(withJSONObject: response, options: [])
        completionHandler?(resData)
    }

    open override func sleep(completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    open override func wake() {
    }
}
#endif
