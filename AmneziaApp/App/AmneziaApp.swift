import SwiftUI
import AmneziaCore

@main
public struct AmneziaApp: App {
    @StateObject private var appState = AppState.shared
    @AppStorage("amnezia_connect_on_launch") private var isConnectOnLaunch: Bool = false
    @AppStorage("awg_privacy_notice_accepted") private var isPrivacyNoticeAccepted: Bool = false

    public init() {
        configureAppAppearance()
    }

    public var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView(appState: appState)
                    .tabItem {
                        Label("Connect", systemImage: "shield.checkered")
                    }

                ServerListView(appState: appState)
                    .tabItem {
                        Label("Servers", systemImage: "server.rack")
                    }

                SettingsView(appState: appState)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .tint(.green)
            .preferredColorScheme(.dark)
            .sheet(isPresented: Binding(
                get: { !isPrivacyNoticeAccepted },
                set: { isPrivacyNoticeAccepted = !$0 }
            )) {
                PrivacyNoticeView()
            }
            .onOpenURL { url in
                handleIncomingUrl(url)
            }
            .onAppear {
                if isConnectOnLaunch && !appState.connectionState.isConnected {
                    appState.toggleConnection()
                }
            }
        }
    }

    private func handleIncomingUrl(_ url: URL) {
        let urlString = url.absoluteString
        do {
            _ = try appState.importFromText(urlString)
            HapticFeedback.notification(type: .success)
        } catch {
            appState.errorMessage = "Failed to import URL: \(error.localizedDescription)"
        }
    }

    private func configureAppAppearance() {
        #if canImport(UIKit)
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(white: 0.08, alpha: 1.0)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(white: 0.04, alpha: 1.0)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        #endif
    }
}
