package org.amnezia.core.vpn

import android.content.Context
import android.content.Intent
import android.net.VpnService
import androidx.core.content.ContextCompat
import kotlinx.coroutines.flow.StateFlow
import org.amnezia.core.models.ConnectionState
import org.amnezia.core.models.ConnectionStats
import org.amnezia.core.models.ServerProfile

/**
 * [VpnTunnelService] backed by the system [AmneziaVpnService].
 *
 * Callers must show the consent dialog returned by [prepareIntent] before the first
 * [startTunnel]; otherwise [VpnPermissionRequiredException] is thrown.
 */
class RealTunnelService(context: Context) : VpnTunnelService {

    private val appContext = context.applicationContext

    override val state: StateFlow<ConnectionState> = AmneziaVpnService.vpnState
    override val stats: StateFlow<ConnectionStats> = AmneziaVpnService.vpnStats

    /** The service does not count bytes until a real WireGuard/AWG backend is integrated. */
    override val providesTrafficStats: Boolean = false

    /** Non-null when the user still has to approve the system VPN consent dialog. */
    fun prepareIntent(): Intent? = VpnService.prepare(appContext)

    override suspend fun startTunnel(profile: ServerProfile, options: TunnelOptions) {
        if (prepareIntent() != null) {
            throw VpnPermissionRequiredException()
        }
        val intent = Intent(appContext, AmneziaVpnService::class.java)
            .setAction(AmneziaVpnService.ACTION_CONNECT)
            .putExtra(AmneziaVpnService.EXTRA_PROFILE_ID, profile.id)
        options.dnsOverride?.takeIf { it.isNotEmpty() }?.let { dns ->
            intent.putExtra(AmneziaVpnService.EXTRA_DNS_OVERRIDE, dns.toTypedArray())
        }
        ContextCompat.startForegroundService(appContext, intent)
    }

    override suspend fun stopTunnel() {
        if (state.value == ConnectionState.Disconnected) return
        val intent = Intent(appContext, AmneziaVpnService::class.java)
            .setAction(AmneziaVpnService.ACTION_DISCONNECT)
        appContext.startService(intent)
    }
}
