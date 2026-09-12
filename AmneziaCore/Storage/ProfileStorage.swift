import Foundation

public final class ProfileStorage: @unchecked Sendable {
    public static let shared = ProfileStorage()

    private let userDefaults: UserDefaults
    private let profilesKey = "amnezia_server_profiles"
    private let selectedIdKey = "amnezia_selected_profile_id"
    private let lock = NSLock()

    public init(appGroupId: String? = nil) {
        if let appGroupId, let groupDefaults = UserDefaults(suiteName: appGroupId) {
            self.userDefaults = groupDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }
    }

    public func loadProfiles() -> [ServerProfile] {
        lock.lock()
        defer { lock.unlock() }

        guard let data = userDefaults.data(forKey: profilesKey),
              let profiles = try? JSONDecoder().decode([ServerProfile].self, from: data) else {
            return []
        }
        return profiles
    }

    public func saveProfiles(_ profiles: [ServerProfile]) {
        lock.lock()
        defer { lock.unlock() }

        if let data = try? JSONEncoder().encode(profiles) {
            userDefaults.set(data, forKey: profilesKey)
        }
    }

    public func addProfile(_ profile: ServerProfile) {
        var existing = loadProfiles()
        // Prevent duplicate IDs
        existing.removeAll { $0.id == profile.id }
        existing.insert(profile, at: 0)
        saveProfiles(existing)

        // If no server was selected, select this one
        if selectedProfileId == nil {
            selectProfile(id: profile.id)
        }
    }

    public func updateProfile(_ profile: ServerProfile) {
        var existing = loadProfiles()
        if let index = existing.firstIndex(where: { $0.id == profile.id }) {
            existing[index] = profile
            saveProfiles(existing)
        }
    }

    public func deleteProfile(id: UUID) {
        var existing = loadProfiles()
        existing.removeAll { $0.id == id }
        saveProfiles(existing)

        if selectedProfileId == id {
            selectProfile(id: existing.first?.id)
        }
    }

    public var selectedProfileId: UUID? {
        lock.lock()
        defer { lock.unlock() }
        guard let idString = userDefaults.string(forKey: selectedIdKey) else { return nil }
        return UUID(uuidString: idString)
    }

    public func selectProfile(id: UUID?) {
        lock.lock()
        defer { lock.unlock() }
        if let id {
            userDefaults.set(id.uuidString, forKey: selectedIdKey)
        } else {
            userDefaults.removeObject(forKey: selectedIdKey)
        }
    }

    public func selectedProfile() -> ServerProfile? {
        let all = loadProfiles()
        guard let selectedId = selectedProfileId else { return all.first }
        return all.first(where: { $0.id == selectedId }) ?? all.first
    }
}
