package org.amnezia.core.storage

import android.content.Context
import android.content.SharedPreferences
import org.amnezia.core.models.DnsProvider

/** Persisted user preferences shared by the phone and TV apps. */
class AppSettings(context: Context) {

    private val prefs: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    var dnsProvider: DnsProvider
        get() = prefs.getString(KEY_DNS_PROVIDER, null)
            ?.let { name -> DnsProvider.entries.firstOrNull { it.name == name } }
            ?: DnsProvider.SERVER_DEFAULT
        set(value) = prefs.edit().putString(KEY_DNS_PROVIDER, value.name).apply()

    var customDns: String
        get() = prefs.getString(KEY_CUSTOM_DNS, "") ?: ""
        set(value) = prefs.edit().putString(KEY_CUSTOM_DNS, value.trim()).apply()

    var connectOnLaunch: Boolean
        get() = prefs.getBoolean(KEY_CONNECT_ON_LAUNCH, false)
        set(value) = prefs.edit().putBoolean(KEY_CONNECT_ON_LAUNCH, value).apply()

    var privacyNoticeAccepted: Boolean
        get() = prefs.getBoolean(KEY_PRIVACY_ACCEPTED, false)
        set(value) = prefs.edit().putBoolean(KEY_PRIVACY_ACCEPTED, value).apply()

    /** Only honoured by debug builds. */
    var simulatedTunnel: Boolean
        get() = prefs.getBoolean(KEY_SIMULATED, false)
        set(value) = prefs.edit().putBoolean(KEY_SIMULATED, value).apply()

    /** DNS servers to push into the tunnel, or null to use the servers from the profile. */
    fun resolveDnsOverride(): List<String>? {
        return when (val provider = dnsProvider) {
            DnsProvider.SERVER_DEFAULT -> null
            DnsProvider.CUSTOM -> customDns
                .split(',', ' ', ';', '\n')
                .map { it.trim() }
                .filter { it.isNotEmpty() }
                .ifEmpty { null }
            else -> provider.servers
        }
    }

    companion object {
        private const val PREFS_NAME = "awg_settings"
        private const val KEY_DNS_PROVIDER = "dns_provider"
        private const val KEY_CUSTOM_DNS = "custom_dns"
        private const val KEY_CONNECT_ON_LAUNCH = "connect_on_launch"
        private const val KEY_PRIVACY_ACCEPTED = "privacy_notice_accepted"
        private const val KEY_SIMULATED = "simulated_tunnel_debug"
    }
}
