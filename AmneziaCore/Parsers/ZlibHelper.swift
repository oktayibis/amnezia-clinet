import Foundation
import zlib

public enum ZlibError: Error, LocalizedError {
    case initializationFailed
    case decompressionFailed(Int32)
    case compressionFailed(Int32)
    case invalidHeader

    public var errorDescription: String? {
        switch self {
        case .initializationFailed:
            return "Failed to initialize zlib stream"
        case .decompressionFailed(let code):
            return "zlib decompression failed with code \(code)"
        case .compressionFailed(let code):
            return "zlib compression failed with code \(code)"
        case .invalidHeader:
            return "Invalid Qt compressed header"
        }
    }
}

public final class ZlibHelper: Sendable {
    
    /// Decompresses Qt `qCompress` payload:
    /// First 4 bytes are big-endian UInt32 with expected uncompressed length.
    /// Remaining bytes are zlib compressed stream.
    public static func decompressQt(_ data: Data) throws -> Data {
        guard data.count > 4 else {
            throw ZlibError.invalidHeader
        }
        
        let expectedLength = Int(data.prefix(4).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
        guard expectedLength > 0 && expectedLength < 50_000_000 else {
            throw ZlibError.invalidHeader
        }
        
        let payload = data.dropFirst(4)
        
        var stream = z_stream()
        guard inflateInit_(&stream, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size)) == Z_OK else {
            throw ZlibError.initializationFailed
        }
        defer { inflateEnd(&stream) }
        
        var decompressed = Data(count: expectedLength)
        let status = payload.withUnsafeBytes { inPtr in
            decompressed.withUnsafeMutableBytes { outPtr in
                stream.next_in = UnsafeMutablePointer(mutating: inPtr.bindMemory(to: Bytef.self).baseAddress)
                stream.avail_in = uInt(payload.count)
                stream.next_out = outPtr.bindMemory(to: Bytef.self).baseAddress
                stream.avail_out = uInt(outPtr.count)
                return inflate(&stream, Z_FINISH)
            }
        }
        
        guard status == Z_STREAM_END || status == Z_OK else {
            throw ZlibError.decompressionFailed(status)
        }
        
        decompressed.count = Int(stream.total_out)
        return decompressed
    }

    /// Compresses data into Qt `qCompress` format (4-byte length prefix + zlib stream)
    public static func compressQt(_ data: Data, level: Int32 = Z_DEFAULT_COMPRESSION) throws -> Data {
        var stream = z_stream()
        guard deflateInit_(&stream, level, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size)) == Z_OK else {
            throw ZlibError.initializationFailed
        }
        defer { deflateEnd(&stream) }
        
        // Estimate output buffer size
        let maxOutputSize = Int(deflateBound(&stream, uLong(data.count)))
        var compressed = Data(count: maxOutputSize)
        
        let status = data.withUnsafeBytes { inPtr in
            compressed.withUnsafeMutableBytes { outPtr in
                stream.next_in = UnsafeMutablePointer(mutating: inPtr.bindMemory(to: Bytef.self).baseAddress)
                stream.avail_in = uInt(data.count)
                stream.next_out = outPtr.bindMemory(to: Bytef.self).baseAddress
                stream.avail_out = uInt(outPtr.count)
                return deflate(&stream, Z_FINISH)
            }
        }
        
        guard status == Z_STREAM_END else {
            throw ZlibError.compressionFailed(status)
        }
        compressed.count = Int(stream.total_out)
        
        // Prepend 4 bytes big endian length
        var result = Data()
        var bigEndianLength = UInt32(data.count).bigEndian
        withUnsafeBytes(of: &bigEndianLength) { result.append(contentsOf: $0) }
        result.append(compressed)
        
        return result
    }
}
