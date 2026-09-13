package org.amnezia.core.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import org.amnezia.core.models.ConnectionState
import org.amnezia.core.models.ConnectionStats
import org.amnezia.core.models.ServerProfile
import org.amnezia.core.storage.ProfileStorage

/**
 * System VPN service. Runs as a foreground service (type `systemExempted`, the type Android
 * reserves for VpnService apps) and builds the TUN interface from the selected [ServerProfile].
 *
 * NOTE: This service does not yet contain a WireGuard/AmneziaWG engine. Until the
 * amneziawg-android backend is integrated, packets written to the TUN interface are not
 * encrypted or forwarded. The app must not be shipped to Google Play in this state.
 */
class AmneziaVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_CONNECT -> {
                val profileId = intent.getStringExtra(EXTRA_PROFILE_ID)
                val dnsOverride = intent.getStringArrayExtra(EXTRA_DNS_OVERRIDE)?.toList()
                connect(profileId, dnsOverride)
            }
            ACTION_DISCONNECT -> disconnect()
            else -> stopSelf()
        }
        return START_NOT_STICKY
    }

    private fun connect(profileId: String?, dnsOverride: List<String>?) {
        val storage = ProfileStorage(applicationContext)
        val profile = profileId?.let { id -> storage.loadProfiles().firstOrNull { it.id == id } }
            ?: storage.selectedProfile()

        if (profile == null) {
            _vpnState.value = ConnectionState.Error("No server profile selected")
            stopSelf()
            return
        }

        _vpnState.value = ConnectionState.Connecting
        startAsForeground(profile)

        try {
            val builder = Builder()
                .setSession(appLabel())
                .setMtu(profile.mtu.coerceIn(1280, 1500))

            val (address, prefix) = splitCidr(profile.clientIp, defaultPrefix = 32)
            builder.addAddress(address, prefix)

            val routes = profile.allowedIps.ifEmpty { listOf("0.0.0.0/0") }
            routes.forEach { cidr ->
                val (routeAddress, routePrefix) = splitCidr(cidr, defaultPrefix = if (cidr.contains(':')) 128 else 32)
                runCatching { builder.addRoute(routeAddress, routePrefix) }
            }

            val dnsServers = dnsOverride?.takeIf { it.isNotEmpty() } ?: profile.dnsServers
            dnsServers.forEach { dns -> runCatching { builder.addDnsServer(dns) } }

            launchIntent()?.let { builder.setConfigureIntent(it) }

            vpnInterface?.close()
            vpnInterface = builder.establish()

            if (vpnInterface != null) {
                _vpnState.value = ConnectionState.Connected
            } else {
                _vpnState.value = ConnectionState.Error("Failed to establish TUN interface")
                stopForegroundAndSelf()
            }
        } catch (e: Exception) {
            _vpnState.value = ConnectionState.Error(e.message ?: "VPN establishment error")
            stopForegroundAndSelf()
        }
    }

    private fun disconnect() {
        if (_vpnState.value != ConnectionState.Disconnected) {
            _vpnState.value = ConnectionState.Disconnecting
        }
        try {
            vpnInterface?.close()
        } catch (_: Exception) {
        }
        vpnInterface = null
        _vpnStats.value = ConnectionStats()
        _vpnState.value = ConnectionState.Disconnected
        stopForegroundAndSelf()
    }

    /** Called by the system when another VPN app takes over or the user revokes consent. */
    override fun onRevoke() {
        disconnect()
        super.onRevoke()
    }

    override fun onDestroy() {
        try {
            vpnInterface?.close()
        } catch (_: Exception) {
        }
        vpnInterface = null
        if (_vpnState.value != ConnectionState.Disconnected) {
            _vpnState.value = ConnectionState.Disconnected
        }
        super.onDestroy()
    }

    // MARK: - Foreground service / notification

    private fun startAsForeground(profile: ServerProfile) {
        val notification = buildNotification(profile)
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED
        } else {
            0
        }
        ServiceCompat.startForeground(this, NOTIFICATION_ID, notification, type)
    }

    private fun stopForegroundAndSelf() {
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun buildNotification(profile: ServerProfile): Notification {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "VPN connection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows while the VPN tunnel is active"
                setShowBadge(false)
            }
            manager.createNotificationChannel(channel)
        }

        val disconnectIntent = PendingIntent.getService(
            this,
            1,
            Intent(this, AmneziaVpnService::class.java).setAction(ACTION_DISCONNECT),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentTitle("${appLabel()} is active")
            .setContentText(profile.name)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(launchIntent())
            .addAction(0, "Disconnect", disconnectIntent)
            .build()
    }

    private fun launchIntent(): PendingIntent? {
        val intent = packageManager.getLaunchIntentForPackage(packageName) ?: return null
        return PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun appLabel(): String =
        applicationInfo.loadLabel(packageManager).toString()

    private fun splitCidr(value: String, defaultPrefix: Int): Pair<String, Int> {
        val parts = value.trim().split('/')
        val address = parts[0]
        val prefix = parts.getOrNull(1)?.toIntOrNull() ?: defaultPrefix
        return address to prefix
    }

    companion object {
        const val ACTION_CONNECT = "org.amnezia.vpn.CONNECT"
        const val ACTION_DISCONNECT = "org.amnezia.vpn.DISCONNECT"
        const val EXTRA_PROFILE_ID = "profile_id"
        const val EXTRA_DNS_OVERRIDE = "dns_override"

        private const val CHANNEL_ID = "vpn_status"
        private const val NOTIFICATION_ID = 1001

        private val _vpnState = MutableStateFlow<ConnectionState>(ConnectionState.Disconnected)
        val vpnState: StateFlow<ConnectionState> = _vpnState.asStateFlow()

        private val _vpnStats = MutableStateFlow(ConnectionStats())
        val vpnStats: StateFlow<ConnectionStats> = _vpnStats.asStateFlow()
    }
}
