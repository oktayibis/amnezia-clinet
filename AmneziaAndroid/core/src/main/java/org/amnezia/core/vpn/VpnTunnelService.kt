package org.amnezia.core.vpn

import kotlinx.coroutines.flow.StateFlow
import org.amnezia.core.models.ConnectionState
import org.amnezia.core.models.ConnectionStats
import org.amnezia.core.models.ServerProfile

interface VpnTunnelService {
    val state: StateFlow<ConnectionState>
    val stats: StateFlow<ConnectionStats>

    suspend fun startTunnel(profile: ServerProfile)
    suspend fun stopTunnel()
}
