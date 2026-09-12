package org.amnezia.core.parsers

import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.zip.Deflater
import java.util.zip.Inflater

object ZlibHelper {

    /**
     * Decompresses data that may be raw zlib or Qt-compressed (4-byte uncompressed size prefix).
     */
    fun decompress(bytes: ByteArray): ByteArray {
        if (bytes.size < 2) return bytes

        // Check if prefixed by 4-byte Qt uncompressed size
        val zlibPayload = if (bytes.size > 4 && bytes[4] == 0x78.toByte()) {
            bytes.copyOfRange(4, bytes.size)
        } else if (bytes[0] == 0x78.toByte()) {
            bytes
        } else {
            bytes
        }

        return try {
            val inflater = Inflater()
            inflater.setInput(zlibPayload)
            val outputStream = ByteArrayOutputStream(zlibPayload.size * 2)
            val buffer = ByteArray(1024)
            while (!inflater.finished()) {
                val count = inflater.inflate(buffer)
                if (count == 0 && inflater.needsInput()) break
                outputStream.write(buffer, 0, count)
            }
            inflater.end()
            outputStream.toByteArray()
        } catch (e: Exception) {
            // Fallback: if not zlib compressed, return as is
            bytes
        }
    }

    /**
     * Compresses data in Qt format (4-byte big endian uncompressed size + zlib payload).
     */
    fun compressQt(bytes: ByteArray): ByteArray {
        val deflater = Deflater(Deflater.BEST_COMPRESSION)
        deflater.setInput(bytes)
        deflater.finish()

        val outputStream = ByteArrayOutputStream()
        // Write 4-byte big endian length
        val sizeBuffer = ByteBuffer.allocate(4).order(ByteOrder.BIG_ENDIAN).putInt(bytes.size).array()
        outputStream.write(sizeBuffer)

        val buffer = ByteArray(1024)
        while (!deflater.finished()) {
            val count = deflater.deflate(buffer)
            outputStream.write(buffer, 0, count)
        }
        deflater.end()
        return outputStream.toByteArray()
    }
}
