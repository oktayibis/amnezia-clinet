import XCTest
@testable import AmneziaCore

final class QrChunkAssemblerTests: XCTestCase {

    func testProcessSingleVpnUrl() throws {
        let assembler = QrCodeChunkAssembler()
        let sampleConf = """
        [Interface]
        Address = 10.8.0.2/32
        PrivateKey = aaaa=
        [Peer]
        PublicKey = bbbb=
        Endpoint = 1.1.1.1:51820
        """

        let result = assembler.processScannedCode(sampleConf)
        switch result {
        case .single(let profile):
            XCTAssertEqual(profile.endpointHost, "1.1.1.1")
        default:
            XCTFail("Expected .single result, got \(result)")
        }
    }

    func testMultiChunkAssembly() throws {
        let assembler = QrCodeChunkAssembler()

        let fullConfigText = """
        [Interface]
        Address = 10.8.0.2/32
        PrivateKey = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=
        DNS = 1.1.1.1
        [Peer]
        PublicKey = bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=
        Endpoint = 192.168.1.1:51820
        """
        let fullData = Data(fullConfigText.utf8)
        let midpoint = fullData.count / 2
        let part1 = fullData.prefix(midpoint)
        let part2 = fullData.dropFirst(midpoint)

        // Helper to build a Qt QDataStream chunk
        func buildChunk(index: UInt8, partData: Data) -> String {
            var chunkData = Data()
            var magic = Int16(1984).bigEndian
            withUnsafeBytes(of: &magic) { chunkData.append(contentsOf: $0) }
            chunkData.append(2) // total chunks = 2
            chunkData.append(index) // chunk index (0 or 1)

            // QByteArray payload size prefix
            var partSize = UInt32(partData.count).bigEndian
            withUnsafeBytes(of: &partSize) { chunkData.append(contentsOf: $0) }
            chunkData.append(partData)

            return AmneziaUrlDecoder.encodeBase64URL(chunkData)
        }

        let chunk0Str = buildChunk(index: 0, partData: part1)
        let chunk1Str = buildChunk(index: 1, partData: part2)

        // Feed chunk 0
        let res0 = assembler.processScannedCode(chunk0Str)
        XCTAssertEqual(res0, .chunkProgress(received: 1, total: 2))

        // Feed chunk 1
        let res1 = assembler.processScannedCode(chunk1Str)
        switch res1 {
        case .completed(let profile):
            XCTAssertEqual(profile.endpointHost, "192.168.1.1")
            XCTAssertEqual(profile.endpointPort, 51820)
        default:
            XCTFail("Expected .completed, got \(res1)")
        }
    }
}
