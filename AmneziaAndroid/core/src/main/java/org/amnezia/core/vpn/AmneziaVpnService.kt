package org.amnezia.core.vpn

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import org.amnezia.core.models.ConnectionState
import org.amnezia.core.models.ConnectionStats
import org.amnezia.core.models.ServerProfile

class AmneziaVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        when (action) {
            ACTION_CONNECT -> {
                connect()
            }
            ACTION_DISCONNECT -> {
                disconnect()
            }
        }
        return START_NOT_STICKY
    }

    private fun connect() {
        try {
            _vpnState.value = ConnectionState.Connecting

            val builder = Builder()
                .setSession("Amnezia VPN")
                .setMtu(1280)
                .addAddress("10.8.0.2", 32)
                .addRoute("0.0.0.0", 0)
                .addDnsServer("1.1.1.1")

            vpnInterface = builder.establish()
            if (vpnInterface != null) {
                _vpnState.value = ConnectionState.Connected
            } else {
                _vpnState.value = ConnectionState.Error("Failed to establish TUN interface")
            }
        } catch (e: Exception) {
            _vpnState.value = ConnectionState.Error(e.message ?: "VPN establishment error")
        }
    }

    private fun disconnect() {
        _vpnState.value = ConnectionState.Disconnecting
        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (e: Exception) {
            // Ignored
        }
        _vpnState.value = ConnectionState.Disconnected
        stopSelf()
    }

    override fun onDestroy() {
        disconnect()
        super.onDestroy()
    }

    companion object {
        const val ACTION_CONNECT = "org.amnezia.vpn.CONNECT"
        const val ACTION_DISCONNECT = "org.amnezia.vpn.DISCONNECT"

        private val _vpnState = MutableStateFlow<ConnectionState>(ConnectionState.Disconnected)
        val vpnState: StateFlow<ConnectionState> = _vpnState.asStateFlow()

        private val _vpnStats = MutableStateFlow(ConnectionStats())
        val vpnStats: StateFlow<ConnectionStats> = _vpnStats.asStateFlow()
    }
}
