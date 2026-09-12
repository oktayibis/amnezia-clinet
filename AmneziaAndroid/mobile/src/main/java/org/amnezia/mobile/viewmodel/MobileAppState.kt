package org.amnezia.mobile.viewmodel

import android.content.ClipboardManager
import android.content.Context
import android.net.Uri
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.amnezia.core.models.ConnectionState
import org.amnezia.core.models.ConnectionStats
import org.amnezia.core.models.ServerProfile
import org.amnezia.core.parsers.AmneziaUrlDecoder
import org.amnezia.core.parsers.WgQuickConfigParser
import org.amnezia.core.storage.ProfileStorage
import org.amnezia.core.vpn.MockTunnelService
import org.amnezia.core.vpn.VpnTunnelService

class MobileAppState(
    private val context: Context,
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main)
) {
    private val storage = ProfileStorage(context)
    private var mockTunnel: MockTunnelService = MockTunnelService()
    var tunnelService: VpnTunnelService = mockTunnel
        private set

    private val _profiles = MutableStateFlow<List<ServerProfile>>(emptyList())
    val profiles: StateFlow<List<ServerProfile>> = _profiles.asStateFlow()

    private val _selectedProfile = MutableStateFlow<ServerProfile?>(null)
    val selectedProfile: StateFlow<ServerProfile?> = _selectedProfile.asStateFlow()

    val connectionState: StateFlow<ConnectionState> get() = tunnelService.state
    val stats: StateFlow<ConnectionStats> get() = tunnelService.stats

    private val _isSimulatedTunnel = MutableStateFlow(true)
    val isSimulatedTunnel: StateFlow<Boolean> = _isSimulatedTunnel.asStateFlow()

    private val _isAddServerPresented = MutableStateFlow(false)
    val isAddServerPresented: StateFlow<Boolean> = _isAddServerPresented.asStateFlow()

    private val _detectedClipboardUrl = MutableStateFlow<String?>(null)
    val detectedClipboardUrl: StateFlow<String?> = _detectedClipboardUrl.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        loadProfiles()
        checkClipboard()
    }

    fun setAddServerPresented(presented: Boolean) {
        _isAddServerPresented.value = presented
    }

    fun clearErrorMessage() {
        _errorMessage.value = null
    }

    fun setSimulatedTunnel(enabled: Boolean) {
        _isSimulatedTunnel.value = enabled
    }

    fun loadProfiles() {
        val loaded = storage.loadProfiles()
        _profiles.value = loaded

        if (loaded.isEmpty()) {
            _selectedProfile.value = null
            return
        }

        val storedSelected = storage.selectedProfile()
        if (storedSelected != null && loaded.any { it.id == storedSelected.id }) {
            _selectedProfile.value = storedSelected
        } else {
            val first = loaded.first()
            _selectedProfile.value = first
            storage.selectProfile(first.id)
        }
    }

    fun selectProfile(profile: ServerProfile) {
        _selectedProfile.value = profile
        storage.selectProfile(profile.id)

        if (connectionState.value.isConnected) {
            scope.launch {
                try {
                    tunnelService.startTunnel(profile)
                } catch (e: Exception) {
                    _errorMessage.value = e.localizedMessage
                }
            }
        }
    }

    fun addProfile(profile: ServerProfile) {
        storage.addProfile(profile)
        loadProfiles()
        selectProfile(profile)
    }

    fun deleteProfile(profile: ServerProfile) {
        if (_selectedProfile.value?.id == profile.id) {
            _selectedProfile.value = null
            if (connectionState.value.isConnected) {
                scope.launch {
                    try {
                        tunnelService.stopTunnel()
                    } catch (e: Exception) {
                        // Ignored
                    }
                }
            }
        }
        storage.deleteProfile(profile.id)
        loadProfiles()
    }

    fun toggleConnection() {
        scope.launch {
            try {
                if (connectionState.value.isConnected || connectionState.value.isBusy) {
                    tunnelService.stopTunnel()
                } else {
                    val profile = _selectedProfile.value
                    if (profile == null) {
                        _isAddServerPresented.value = true
                        return@launch
                    }
                    tunnelService.startTunnel(profile)
                }
            } catch (e: Exception) {
                _errorMessage.value = e.localizedMessage ?: "Connection error"
            }
        }
    }

    fun importFromText(input: String): ServerProfile {
        val trimmed = input.trim()
        val profile = when {
            trimmed.lowercase().startsWith("vpn://") -> AmneziaUrlDecoder.decode(trimmed)
            trimmed.contains("[Interface]") && trimmed.contains("[Peer]") -> WgQuickConfigParser.parse(trimmed)
            trimmed.startsWith("{") -> AmneziaUrlDecoder.decode(trimmed)
            else -> AmneziaUrlDecoder.decode("vpn://$trimmed")
        }
        addProfile(profile)
        _detectedClipboardUrl.value = null
        return profile
    }

    fun importFromUri(uri: Uri): ServerProfile {
        val content = context.contentResolver.openInputStream(uri)?.use {
            it.bufferedReader().readText()
        } ?: throw IllegalArgumentException("Could not read file content")
        return importFromText(content)
    }

    fun checkClipboard() {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
        val clip = clipboard?.primaryClip
        if (clip != null && clip.itemCount > 0) {
            val text = clip.getItemAt(0)?.text?.toString()?.trim() ?: return
            if (text.startsWith("vpn://") || (text.contains("[Interface]") && text.contains("[Peer]"))) {
                _detectedClipboardUrl.value = text
            }
        }
    }

    fun dismissClipboardBanner() {
        _detectedClipboardUrl.value = null
    }
}
