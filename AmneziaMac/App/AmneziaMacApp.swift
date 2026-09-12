import SwiftUI
import AppKit
import AmneziaCore

@main
struct AmneziaMacApp: App {
    @StateObject private var appState = MacAppState()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        // Main Application Window
        WindowGroup(id: "main") {
            MacMainView(appState: appState)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    handleIncomingUrl(url)
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 840, height: 580)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .newItem) {}
        }

        // Menu Bar Extra Status Item
        MenuBarExtra {
            MacMenuBarView(appState: appState) {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first(where: { $0.canBecomeKey }) {
                    window.makeKeyAndOrderFront(nil)
                } else {
                    openWindow(id: "main")
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: menuBarIconName)
                if appState.connectionState.isConnected {
                    Text("ON")
                        .font(.system(size: 9, weight: .black))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarIconName: String {
        switch appState.connectionState {
        case .connected:
            return "shield.checkered"
        case .connecting, .reconnecting:
            return "shield.lefthalf.filled"
        case .disconnecting, .disconnected, .error:
            return "shield"
        }
    }

    private func handleIncomingUrl(_ url: URL) {
        let urlString = url.absoluteString
        do {
            _ = try appState.importFromText(urlString)
        } catch {
            appState.errorMessage = "Failed to import URL: \(error.localizedDescription)"
        }
    }
}
