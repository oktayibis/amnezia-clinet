package org.amnezia.core.models

import kotlinx.serialization.Serializable
import java.util.UUID

@Serializable
data class ServerProfile(
    val id: String = UUID.randomUUID().toString(),
    var name: String = "Amnezia Server",
    var protocolType: ProtocolType = ProtocolType.AMNEZIA_WG,
    var host: String = "",
    var port: Int = 51820,
    var clientIp: String = "10.0.0.2/32",
    var dnsServers: List<String> = listOf("1.1.1.1", "1.0.0.1"),
    var publicKey: String = "",
    var privateKey: String = "",
    var presharedKey: String? = null,
    var allowedIps: List<String> = listOf("0.0.0.0/0", "::/0"),
    // AmneziaWG Obfuscation parameters
    var jc: Int? = null,
    var jmin: Int? = null,
    var jmax: Int? = null,
    var s1: Int? = null,
    var s2: Int? = null,
    var h1: Long? = null,
    var h2: Long? = null,
    var h3: Long? = null,
    var h4: Long? = null,
    var mtu: Int = 1280,
    var pingMs: Long? = null,
    var flagEmoji: String = "🌐"
) {
    val endpointString: String
        get() = if (host.isNotEmpty()) "$host:$port" else "Not configured"

    val protocol: ProtocolType
        get() = protocolType
}
