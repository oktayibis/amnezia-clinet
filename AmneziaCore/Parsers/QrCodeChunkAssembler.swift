import Foundation

public enum QrScanResult: Equatable, Sendable {
    case single(ServerProfile)
    case chunkProgress(received: Int, total: Int)
    case completed(ServerProfile)
    case invalid(String)
}

public final class QrCodeChunkAssembler: @unchecked Sendable {
    public static let qrMagicCode: Int16 = 1984

    private var totalChunks: UInt8 = 0
    private var chunks = [UInt8: Data]()
    private let lock = NSLock()

    public init() {}

    /// Resets any partially assembled chunks
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        totalChunks = 0
        chunks.removeAll()
    }

    /// Feeds a scanned QR string into the assembler
    public func processScannedCode(_ text: String) -> QrScanResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. Check if it's a standard single QR code
        if trimmed.lowercased().hasPrefix("vpn://") {
            do {
                let profile = try AmneziaUrlDecoder.decode(trimmed)
                return .single(profile)
            } catch {
                return .invalid("Failed to decode Amnezia URL: \(error.localizedDescription)")
            }
        }

        if trimmed.contains("[Interface]") && trimmed.contains("[Peer]") {
            do {
                let profile = try WgQuickConfigParser.parse(trimmed)
                return .single(profile)
            } catch {
                return .invalid("Failed to parse WireGuard config: \(error.localizedDescription)")
            }
        }

        // 2. Check if it's Base64URL data (could be chunk or uncompressed single config)
        guard let data = AmneziaUrlDecoder.decodeBase64URL(trimmed) else {
            return .invalid("Unrecognized QR code format")
        }

        // Check if data is multi-chunk format
        if let chunkInfo = parseChunk(data) {
            return handleChunk(chunkInfo)
        }

        // 3. Otherwise try decoding raw data as Amnezia URL/JSON
        do {
            let profile = try AmneziaUrlDecoder.decode(trimmed)
            return .single(profile)
        } catch {
            return .invalid("Could not parse QR data")
        }
    }

    // MARK: - Chunk Parsing & Handling

    private struct ChunkInfo {
        let count: UInt8
        let index: UInt8
        let data: Data
    }

    private func parseChunk(_ data: Data) -> ChunkInfo? {
        // Minimum size: 2 bytes magic + 1 byte count + 1 byte index + at least 4 bytes payload length + 1 byte data
        guard data.count >= 8 else { return nil }

        // Read magic (int16 big-endian)
        let magic = data.prefix(2).withUnsafeBytes { $0.load(as: Int16.self).bigEndian }
        guard magic == Self.qrMagicCode else { return nil }

        let count = data[2]
        let index = data[3]

        // In Qt QDataStream, QByteArray is prefixed with UInt32 big-endian size
        guard count > 0, index < count else { return nil }

        var payloadData: Data
        if data.count >= 8 {
            let byteCount = Int(data.subdata(in: 4..<8).withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
            if data.count >= 8 + byteCount {
                payloadData = data.subdata(in: 8..<(8 + byteCount))
            } else {
                payloadData = data.dropFirst(4)
            }
        } else {
            payloadData = data.dropFirst(4)
        }

        return ChunkInfo(count: count, index: index, data: payloadData)
    }

    private func handleChunk(_ chunk: ChunkInfo) -> QrScanResult {
        lock.lock()
        defer { lock.unlock() }

        if totalChunks != chunk.count {
            totalChunks = chunk.count
            chunks.removeAll()
        }

        chunks[chunk.index] = chunk.data

        if chunks.count == Int(totalChunks) {
            // Reassemble all chunks in order
            var fullData = Data()
            for i in 0..<totalChunks {
                if let part = chunks[i] {
                    fullData.append(part)
                }
            }

            // Reset state
            totalChunks = 0
            chunks.removeAll()

            // Try decoding reassembled payload
            if let decodedStr = String(data: fullData, encoding: .utf8) {
                if let profile = try? AmneziaUrlDecoder.decode(decodedStr) {
                    return .completed(profile)
                }
                if let profile = try? WgQuickConfigParser.parse(decodedStr) {
                    return .completed(profile)
                }
            }

            // Try decoding as compressed Qt data
            if let decompressed = try? ZlibHelper.decompressQt(fullData),
               let jsonStr = String(data: decompressed, encoding: .utf8),
               let profile = try? AmneziaUrlDecoder.decode(jsonStr) {
                return .completed(profile)
            }

            return .invalid("Assembled multi-chunk data could not be parsed")
        }

        return .chunkProgress(received: chunks.count, total: Int(totalChunks))
    }
}
