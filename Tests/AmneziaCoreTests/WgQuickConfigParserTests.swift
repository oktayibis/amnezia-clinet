import XCTest
@testable import AmneziaCore

final class WgQuickConfigParserTests: XCTestCase {

    func testParseAmneziaWgConf() throws {
        let conf = """
        [Interface]
        Address = 10.8.0.2/32, fd00::2/64
        PrivateKey = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=
        DNS = 1.1.1.1, 1.0.0.1
        MTU = 1360
        Jc = 4
        Jmin = 40
        Jmax = 70
        S1 = 15
        S2 = 30
        H1 = 10000001
        H2 = 10000002
        H3 = 10000003
        H4 = 10000004

        [Peer]
        PublicKey = bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=
        PresharedKey = ccccccccccccccccccccccccccccccccccccccccccc=
        Endpoint = 203.0.113.10:51820
        AllowedIPs = 0.0.0.0/0, ::/0
        PersistentKeepalive = 25
        """

        let profile = try WgQuickConfigParser.parse(conf, profileName: "Test AWG")

        XCTAssertEqual(profile.name, "Test AWG")
        XCTAssertEqual(profile.protocolType, .amneziaWg)
        XCTAssertEqual(profile.endpointHost, "203.0.113.10")
        XCTAssertEqual(profile.endpointPort, 51820)
        XCTAssertEqual(profile.clientAddresses, ["10.8.0.2/32", "fd00::2/64"])
        XCTAssertEqual(profile.dnsServers, ["1.1.1.1", "1.0.0.1"])
        XCTAssertEqual(profile.mtu, 1360)
        XCTAssertEqual(profile.persistentKeepalive, 25)

        let awg = try XCTUnwrap(profile.awgParameters)
        XCTAssertEqual(awg.jc, 4)
        XCTAssertEqual(awg.jmin, 40)
        XCTAssertEqual(awg.jmax, 70)
        XCTAssertEqual(awg.s1, 15)
        XCTAssertEqual(awg.s2, 30)
        XCTAssertEqual(awg.h1, "10000001")
        XCTAssertEqual(awg.h2, "10000002")
        XCTAssertEqual(awg.h3, "10000003")
        XCTAssertEqual(awg.h4, "10000004")

        // Roundtrip serialization
        let serialized = WgQuickConfigParser.serialize(profile)
        XCTAssertTrue(serialized.contains("Jc = 4"))
        XCTAssertTrue(serialized.contains("H1 = 10000001"))
        XCTAssertTrue(serialized.contains("Endpoint = 203.0.113.10:51820"))
    }

    func testParseStandardWireGuardConf() throws {
        let conf = """
        [Interface]
        Address = 10.0.0.2/32
        PrivateKey = Key123456789=
        DNS = 8.8.8.8

        [Peer]
        PublicKey = Key987654321=
        Endpoint = 192.0.2.1:51820
        AllowedIPs = 0.0.0.0/0
        """

        let profile = try WgQuickConfigParser.parse(conf)
        XCTAssertEqual(profile.protocolType, .wireGuard)
        XCTAssertNil(profile.awgParameters)
    }
}
