import SwiftUI
import UniformTypeIdentifiers
import AmneziaCore

public enum MacTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case servers = "Servers"
    case settings = "Settings"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .dashboard: return "bolt.shield.fill"
        case .servers: return "server.rack"
        case .settings: return "gearshape.fill"
        }
    }
}

public struct MacMainView: View {
    @ObservedObject var appState: MacAppState
    @State private var selectedTab: MacTab? = .dashboard
    @State private var isTargetedForDrop = false

    public init(appState: MacAppState) {
        self.appState = appState
    }

    public var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 280)
        } detail: {
            detailContent
        }
        .frame(minWidth: 720, minHeight: 520)
        .onDrop(of: [.fileURL], isTargeted: $isTargetedForDrop) { providers in
            handleDrop(providers: providers)
        }
        .overlay {
            if isTargetedForDrop {
                ZStack {
                    Color.black.opacity(0.65)
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 54))
                            .foregroundColor(.green)
                        Text("Drop .vpn or .conf to Import")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(40)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green, lineWidth: 2)
                    )
                }
                .transition(.opacity)
            }
        }
        .alert("AWG Connect", isPresented: Binding(
            get: { appState.errorMessage != nil },
            set: { if !$0 { appState.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                appState.errorMessage = nil
            }
        } message: {
            if let msg = appState.errorMessage {
                Text(msg)
            }
        }
    }

    // MARK: - Sidebar
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            // App Title Header
            HStack(spacing: 10) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.green)

                Text("AWG CONNECT")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Navigation Links
            List(selection: $selectedTab) {
                ForEach(MacTab.allCases) { tab in
                    NavigationLink(value: tab) {
                        Label {
                            HStack {
                                Text(tab.rawValue)
                                Spacer()
                                if tab == .servers && !appState.profiles.isEmpty {
                                    Text("\(appState.profiles.count)")
                                        .font(.system(size: 11, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.white.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                        } icon: {
                            Image(systemName: tab.icon)
                                .foregroundColor(selectedTab == tab ? .green : .secondary)
                        }
                    }
                }
            }
            .listStyle(.sidebar)

            Spacer()

            // Quick Status Pill Footer
            HStack(spacing: 8) {
                Circle()
                    .fill(appState.connectionState.isConnected ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)

                Text(appState.connectionState.isConnected ? "Connected" : "Disconnected")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: { appState.toggleConnection() }) {
                    Image(systemName: "power")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(appState.connectionState.isConnected ? .red : .green)
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(Color.white.opacity(0.04))
        }
    }

    // MARK: - Detail Content
    @ViewBuilder
    private var detailContent: some View {
        switch selectedTab {
        case .dashboard, .none:
            MacDashboardView(appState: appState) {
                selectedTab = .servers
            }
        case .servers:
            MacServerListView(appState: appState)
        case .settings:
            MacSettingsView(appState: appState)
        }
    }

    // MARK: - Drop Handling
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }

                DispatchQueue.main.async {
                    do {
                        _ = try appState.importFromFile(url: url)
                        selectedTab = .servers
                    } catch {
                        appState.errorMessage = error.localizedDescription
                    }
                }
            }
        }
        return true
    }
}
