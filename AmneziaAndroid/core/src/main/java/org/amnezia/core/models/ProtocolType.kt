package org.amnezia.core.models

import kotlinx.serialization.Serializable

@Serializable
enum class ProtocolType(val rawValue: String, val badgeTitle: String) {
    AMNEZIA_WG("amnezia_wg", "AWG (Obfuscated)"),
    WIREGUARD("wireguard", "WireGuard"),
    OPENVPN("openvpn", "OpenVPN"),
    SHADOWSOCKS("shadowsocks", "Shadowsocks"),
    CLOAK("cloak", "Cloak"),
    XRAY("xray", "XRay");

    val displayName: String
        get() = badgeTitle

    companion object {
        fun fromString(value: String): ProtocolType {
            val normalized = value.lowercase().trim()
            return when {
                normalized.contains("awg") || normalized.contains("amnezia") -> AMNEZIA_WG
                normalized.contains("wireguard") || normalized == "wg" -> WIREGUARD
                normalized.contains("openvpn") || normalized == "ovpn" -> OPENVPN
                normalized.contains("shadowsocks") || normalized == "ss" -> SHADOWSOCKS
                normalized.contains("cloak") -> CLOAK
                normalized.contains("xray") || normalized.contains("vless") -> XRAY
                else -> WIREGUARD
            }
        }
    }
}
