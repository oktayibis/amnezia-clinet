import SwiftUI
import AppKit
import UniformTypeIdentifiers
import AmneziaCore

public struct MacServerListView: View {
    @ObservedObject var appState: MacAppState
    @State private var isFileImporterPresented = false
    @State private var isManualInputPresented = false
    @State private var manualInputText = ""
    @State private var profileToRename: ServerProfile? = nil
    @State private var renameText = ""
    @State private var isHoveringDropZone = false

    public init(appState: MacAppState) {
        self.appState = appState
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Toolbar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SERVERS")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(appState.profiles.count) configured profiles")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { isFileImporterPresented = true }) {
                    Label("Import File", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)

                Button(action: { isManualInputPresented = true }) {
                    Label("Add URL / Key", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(24)

            Divider()

            if appState.profiles.isEmpty {
                emptyDropZone
            } else {
                serverList
            }
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.plainText, .json, UTType(filenameExtension: "vpn") ?? .plainText, UTType(filenameExtension: "conf") ?? .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    do {
                        _ = try appState.importFromFile(url: url)
                    } catch {
                        appState.errorMessage = error.localizedDescription
                    }
                } else {
                    do {
                        _ = try appState.importFromFile(url: url)
                    } catch {
                        appState.errorMessage = error.localizedDescription
                    }
                }
            case .failure(let error):
                appState.errorMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $isManualInputPresented) {
            manualInputSheet
        }
        .sheet(item: $profileToRename) { profile in
            renameSheet(profile: profile)
        }
    }

    // MARK: - Server List
    private var serverList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(appState.profiles) { profile in
                    serverRow(profile: profile)
                }
            }
            .padding(24)
        }
    }

    private func serverRow(profile: ServerProfile) -> some View {
        let isSelected = appState.selectedProfile?.id == profile.id

        return MacGlassCard(
            cornerRadius: 12,
            strokeColor: isSelected ? Color.green.opacity(0.4) : Color.white.opacity(0.08)
        ) {
            HStack(spacing: 16) {
                // Radio indicator
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .green : .secondary)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(profile.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)

                        Text(profile.protocolType.badgeTitle)
                            .font(.system(size: 10, weight: .heavy))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(profile.protocolType == .amneziaWg ? Color.purple.opacity(0.3) : Color.blue.opacity(0.3))
                            .foregroundColor(profile.protocolType == .amneziaWg ? .purple : .blue)
                            .clipShape(Capsule())
                    }

                    Text(profile.endpointString)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Actions Menu
                Menu {
                    Button("Select Server") {
                        appState.selectProfile(profile)
                    }

                    Button("Rename...") {
                        renameText = profile.name
                        profileToRename = profile
                    }

                    Button("Copy Config") {
                        let serialized = WgQuickConfigParser.serialize(profile)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(serialized, forType: .string)
                    }

                    Divider()

                    Button("Delete", role: .destructive) {
                        appState.deleteProfile(profile)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 28)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 32)
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                appState.selectProfile(profile)
            }
        }
    }

    // MARK: - Empty Drop Zone
    private var emptyDropZone: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "arrow.down.doc.fill")
                .font(.system(size: 48))
                .foregroundColor(isHoveringDropZone ? .green : .secondary)
                .scaleEffect(isHoveringDropZone ? 1.1 : 1.0)
                .animation(.spring(), value: isHoveringDropZone)

            VStack(spacing: 6) {
                Text("Drag & Drop Config Files Here")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text("Supports .vpn and WireGuard .conf configuration files")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                Button("Browse File...") {
                    isFileImporterPresented = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button("Paste URL / Config") {
                    isManualInputPresented = true
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    // MARK: - Sheets
    private var manualInputSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Add Connection / Server")
                .font(.system(size: 18, weight: .bold))

            Text("Paste a vpn:// link, awgconnect:// URL, or raw WireGuard/AmneziaWG [Interface] configuration:")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            TextEditor(text: $manualInputText)
                .font(.system(size: 12, design: .monospaced))
                .padding(8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
                .frame(height: 140)

            HStack {
                Button("Paste from Clipboard") {
                    if let string = NSPasteboard.general.string(forType: .string) {
                        manualInputText = string
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundColor(.accentColor)

                Spacer()

                Button("Cancel") {
                    isManualInputPresented = false
                    manualInputText = ""
                }
                .buttonStyle(.bordered)

                Button("Add Server") {
                    do {
                        _ = try appState.importFromText(manualInputText)
                        isManualInputPresented = false
                        manualInputText = ""
                    } catch {
                        appState.errorMessage = error.localizedDescription
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(manualInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 480)
    }

    private func renameSheet(profile: ServerProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rename Server")
                .font(.system(size: 16, weight: .bold))

            TextField("Server Name", text: $renameText)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()

                Button("Cancel") {
                    profileToRename = nil
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        appState.renameProfile(profile, to: trimmed)
                    }
                    profileToRename = nil
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(20)
        .frame(width: 340)
    }
}
