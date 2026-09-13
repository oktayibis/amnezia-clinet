package org.amnezia.core.vpn

import kotlinx.coroutines.flow.StateFlow
import org.amnezia.core.models.ConnectionState
import org.amnezia.core.models.ConnectionStats
import org.amnezia.core.models.ServerProfile

/** Per-connection options resolved from user settings at connect time. */
data class TunnelOptions(
    /** DNS servers that replace the ones from the imported profile, or null to keep the profile's. */
    val dnsOverride: List<String>? = null
)

/** Thrown when the system VPN consent dialog must be shown before a tunnel can start. */
class VpnPermissionRequiredException : Exception("VPN permission has not been granted yet")

interface VpnTunnelService {
    val state: StateFlow<ConnectionState>
    val stats: StateFlow<ConnectionStats>

    /** False when the backend cannot report real byte counters; UI must hide traffic meters. */
    val providesTrafficStats: Boolean

    suspend fun startTunnel(profile: ServerProfile, options: TunnelOptions = TunnelOptions())
    suspend fun stopTunnel()
}
