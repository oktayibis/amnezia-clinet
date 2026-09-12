import XCTest
@testable import AmneziaCore

final class ZlibHelperTests: XCTestCase {

    func testQtCompressionAndDecompressionRoundtrip() throws {
        let originalString = "{\"description\":\"My Fast Server\",\"containers\":[{\"container\":\"amnezia-awg\"}]}"
        let originalData = try XCTUnwrap(originalString.data(using: .utf8))

        // Compress to Qt format
        let compressed = try ZlibHelper.compressQt(originalData)
        XCTAssertGreaterThan(compressed.count, 4)

        // Decompress
        let decompressed = try ZlibHelper.decompressQt(compressed)
        let resultString = String(data: decompressed, encoding: .utf8)

        XCTAssertEqual(resultString, originalString)
    }

    func testInvalidHeaderThrowsError() {
        let invalidData = Data([0x00, 0x01]) // less than 4 bytes
        XCTAssertThrowsError(try ZlibHelper.decompressQt(invalidData))
    }
}
