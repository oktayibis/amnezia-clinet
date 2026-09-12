import XCTest
@testable import AmneziaCore

final class ProfileStorageTests: XCTestCase {

    func testAddAndRetrieveProfile() {
        let storage = ProfileStorage(appGroupId: "test_suite_\(UUID().uuidString)")
        
        let profile = ServerProfile(
            name: "Test Server",
            endpointHost: "1.2.3.4",
            endpointPort: 51820,
            clientPrivateKey: "privKey==",
            serverPublicKey: "pubKey==",
            clientAddresses: ["10.8.0.2/32"]
        )

        storage.addProfile(profile)
        let loaded = storage.loadProfiles()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.name, "Test Server")
        XCTAssertEqual(storage.selectedProfile()?.id, profile.id)

        // Delete
        storage.deleteProfile(id: profile.id)
        XCTAssertEqual(storage.loadProfiles().count, 0)
    }
}
