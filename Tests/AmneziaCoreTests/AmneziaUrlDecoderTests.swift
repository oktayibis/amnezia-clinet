import XCTest
@testable import AmneziaCore

final class AmneziaUrlDecoderTests: XCTestCase {

    func testDecodeAmneziaJsonAndEncodeRoundtrip() throws {
        let sampleProfile = ServerProfile(
            name: "Frankfurt AmneziaWG",
            protocolType: .amneziaWg,
            endpointHost: "198.51.100.25",
            endpointPort: 51820,
            clientPrivateKey: "yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=",
            serverPublicKey: "HIgoByamLBM63vLzGsm53+zR2yv8a0Q9G4v0vXgZ5xU=",
            presharedKey: "pskSecret1234567890abcdef=",
            clientAddresses: ["10.8.0.2/32"],
            dnsServers: ["1.1.1.1", "1.0.0.1"],
            allowedIps: ["0.0.0.0/0", "::/0"],
            mtu: 1280,
            persistentKeepalive: 25,
            awgParameters: AwgParameters(
                jc: 4,
                jmin: 40,
                jmax: 70,
                s1: 15,
                s2: 30,
                h1: "12345678",
                h2: "87654321",
                h3: "11223344",
                h4: "44332211"
            )
        )

        // Encode to vpn:// URL
        let urlString = try AmneziaUrlDecoder.encodeToUrl(sampleProfile)
        XCTAssertTrue(urlString.hasPrefix("vpn://"))

        // Decode from vpn:// URL
        let decodedProfile = try AmneziaUrlDecoder.decode(urlString)

        XCTAssertEqual(decodedProfile.name, sampleProfile.name)
        XCTAssertEqual(decodedProfile.protocolType, .amneziaWg)
        XCTAssertEqual(decodedProfile.endpointHost, "198.51.100.25")
        XCTAssertEqual(decodedProfile.endpointPort, 51820)
        XCTAssertEqual(decodedProfile.clientPrivateKey, sampleProfile.clientPrivateKey)
        XCTAssertEqual(decodedProfile.serverPublicKey, sampleProfile.serverPublicKey)
        XCTAssertEqual(decodedProfile.presharedKey, sampleProfile.presharedKey)
        XCTAssertEqual(decodedProfile.clientAddresses, ["10.8.0.2/32"])
        XCTAssertEqual(decodedProfile.dnsServers, ["1.1.1.1", "1.0.0.1"])
        XCTAssertEqual(decodedProfile.mtu, 1280)
        XCTAssertEqual(decodedProfile.persistentKeepalive, 25)

        // Check AWG Obfuscation parameters
        let awg = try XCTUnwrap(decodedProfile.awgParameters)
        XCTAssertEqual(awg.jc, 4)
        XCTAssertEqual(awg.jmin, 40)
        XCTAssertEqual(awg.jmax, 70)
        XCTAssertEqual(awg.s1, 15)
        XCTAssertEqual(awg.s2, 30)
        XCTAssertEqual(awg.h1, "12345678")
        XCTAssertEqual(awg.h2, "87654321")
        XCTAssertEqual(awg.h3, "11223344")
        XCTAssertEqual(awg.h4, "44332211")
    }

    func testDecodeRawJsonString() throws {
        let jsonStr = """
        {
          "containers": [
            {
              "container": "amnezia-wireguard",
              "wireguard": {
                "last_config": "{\\"clientPrivKey\\":\\"AAAA...\\",\\"serverPubKey\\":\\"BBBB...\\",\\"clientIp\\":\\"10.0.0.5/32\\",\\"hostName\\":\\"vpn.example.com\\",\\"port\\":51820}"
              }
            }
          ],
          "description": "Standard WireGuard Server",
          "dns1": "8.8.8.8"
        }
        """

        let profile = try AmneziaUrlDecoder.decode(jsonStr)
        XCTAssertEqual(profile.name, "Standard WireGuard Server")
        XCTAssertEqual(profile.protocolType, .wireGuard)
        XCTAssertEqual(profile.endpointHost, "vpn.example.com")
        XCTAssertEqual(profile.endpointPort, 51820)
        XCTAssertEqual(profile.dnsServers, ["8.8.8.8"])
    }
}
