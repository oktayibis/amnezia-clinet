package org.amnezia.core.models

sealed interface ConnectionState {
    data object Disconnected : ConnectionState
    data object Connecting : ConnectionState
    data object Connected : ConnectionState
    data object Reconnecting : ConnectionState
    data object Disconnecting : ConnectionState
    data class Error(val message: String) : ConnectionState

    val isConnected: Boolean
        get() = this is Connected

    val isConnecting: Boolean
        get() = this is Connecting || this is Reconnecting

    val isBusy: Boolean
        get() = isConnecting || this is Disconnecting
}
