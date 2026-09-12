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

    func testRealUserPastedUrl() throws {
        let realUrl = "vpn://AAALTXjatVZbT-M4FH7nV1TVvC0UO7ZzQcNIBco0MNP7LhQyqtLEbbNNk5BLoYP47-tL2qbCPLDSpCCffN9nn2P7HMevRzX21L04yt0gomlWP6s9Cow_rztLqNznOaMPQUG0IcPrEBFICNKJeQItDVhAs7BWP1bINSG3TGJqGGraiQYQtAg0IVTKEZdrEABgmoaJTjQILQtCSEylHEu5ZhrYNIDO5JoFiGVipJLbIvavaU379nVaAy8sKOYIwPJfPrpu6Uj39JlBdAwQs2e6D3Y6DwCv2gcC4rIGY5-YyEDGN6VjsQpKBn3I4A8Z8hFz43EGK6mV-8JJAtRsEImNUrJDueeQKEkxN6QrOTE7ZCg5MT9LRYVulk9Yns4CnoT1VyfisMNyz2Hvjjr7nPrxTqeVOlXaVXVI6pT5VtXhrU6RaBWdXcb3hzOs6rGcaRVC7yH8HiLvoBtPQriKsayRKAEHcBCVS1yFh9v9gaSKljEivQqWUSKjCpZxWhXMDcP4mfqTIMk4-ShxyYGG-J3uY5D42RmHJPJrN5IXBjTKbV_6WNqXneX9IH1yl3ded7y5mJs3eDT_uf53OVjlfTcpfhSrTLtvXeDzSjhyEBbNdvoNswEb-ntFkgbryZJupG6RP4HNjzAbd-lVv40fMEHjsUEG-bxveIvZYDb3v_9jrJebUazwlhTT_VD_N3BRTnKIRzvKaTpzPfrLcaKm76c0y2rnte1sTpHG8KvOkGFfegP7Z3MwnrDX49qXYeuy27kq35mox6bp5vSWbpj2U7N0ohuP9cHcYOkk3AvbfWE24fYQcpQlEzM1ZrIMYhbilsEtzCyLGW2hUx4KjOQ91ScBI_lg6vJnJBakquadyOY-_3ShMzc8et6issVlS2TL_h57lKZ8I3vFNAw8uRVg2rTSFRh9vyg6hh3AUe7dze_uV6fAa-Ewot5fF_1Z9_r6edE_F9tIs4WbUl_27objgsxo2zMf7tyH0ejZM8hTu7XR6XUSxfYm-9u_vV1AGC-bvHdT1qjd40m0K8rjmqhDJ2pFfhIHUc53CzcgMhtsexqQ4DOEEeR72mO3kSDLWa7fUpq4YbCmfOn5xldSeBFnecdd0fKQOBiqIlvlxfYzYVQLM9k5YcVEk4lwUx7s1fMqidOcwyK4PZot9zX4qfXZj5zRdE3Tw3L-1EaxM-3NiVSfTB60-NbyoJWCNM5jLw4na74MsfjaK29sWTGNaD5x5akgLwXiWFBeDfLUjTLufCIccHnhJ_UD4dthv_0NlKvdVUR_B-4Ju3Bq-25vR_LslldWn87cIswvP-y302VeGiR5Ob2hWO4a3NFRJi8yDfGrwPKSKhJ3B2-zTdxSDnKtfvR29B9c7L1y"
        
        let profile = try AmneziaUrlDecoder.decode(realUrl)
        XCTAssertEqual(profile.name, "Server 1")
        XCTAssertEqual(profile.protocolType, .amneziaWg)
        XCTAssertEqual(profile.endpointHost, "94.138.209.154")
        XCTAssertEqual(profile.endpointPort, 34316)
        XCTAssertEqual(profile.clientPrivateKey, "htq0yLlsYOeDQH4Z453YY75RtgQ7chfRfgdGV7vkyTo=")
        XCTAssertEqual(profile.serverPublicKey, "0bA9rm0TGBuN7Ii1TtcWgWXm/0cE4lnec+BQfOFFwhQ=")
        XCTAssertEqual(profile.presharedKey, "OlYu5feHc8ZWaZTTwc75qHEy6eFpnoIysUdKKh11okA=")
        XCTAssertEqual(profile.clientAddresses, ["10.8.1.6/32"])
        XCTAssertEqual(profile.dnsServers, ["1.1.1.1", "1.0.0.1"])
        XCTAssertEqual(profile.allowedIps, ["0.0.0.0/0", "::/0"])
        XCTAssertEqual(profile.mtu, 1376)
        XCTAssertEqual(profile.persistentKeepalive, 25)

        let awg = try XCTUnwrap(profile.awgParameters)
        XCTAssertEqual(awg.jc, 4)
        XCTAssertEqual(awg.jmin, 10)
        XCTAssertEqual(awg.jmax, 50)
        XCTAssertEqual(awg.s1, 115)
        XCTAssertEqual(awg.s2, 36)
        XCTAssertEqual(awg.s3, 37)
        XCTAssertEqual(awg.s4, 9)
        XCTAssertEqual(awg.h1, "1351553658-1920902942")
        XCTAssertEqual(awg.h2, "1985824122-2031951811")
        XCTAssertEqual(awg.h3, "2100088783-2119911158")
        XCTAssertEqual(awg.h4, "2128748706-2129059843")
        XCTAssertEqual(awg.i1, "<r 2><b 0x858000010001000000000669636c6f756403636f6d0000010001c00c000100010000105a00044d583737>")
    }
}
