package org.amnezia.mobile

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.amnezia.mobile.ui.components.AppNavigationBar
import org.amnezia.mobile.ui.screens.AddServerBottomSheet
import org.amnezia.mobile.ui.screens.DashboardScreen
import org.amnezia.mobile.ui.screens.PrivacyNoticeScreen
import org.amnezia.mobile.ui.screens.ServersScreen
import org.amnezia.mobile.ui.screens.SettingsScreen
import org.amnezia.mobile.ui.theme.AmneziaTheme
import org.amnezia.mobile.viewmodel.MobileAppState

class MainActivity : ComponentActivity() {

    private lateinit var appState: MobileAppState

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        appState = (application as AmneziaMobileApp).appState
        handleIntent(intent)

        setContent {
            AmneziaTheme {
                var privacyAccepted by remember { mutableStateOf(appState.settings.privacyNoticeAccepted) }

                if (!privacyAccepted) {
                    // Google Play VpnService policy: disclose data handling before any VPN use.
                    PrivacyNoticeScreen(onAccept = {
                        appState.settings.privacyNoticeAccepted = true
                        privacyAccepted = true
                    })
                } else {
                    MainAppScaffold(appState = appState)
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val uri = intent?.data ?: return
        val urlString = uri.toString()
        val payload = when {
            urlString.startsWith("vpn://") -> urlString
            urlString.startsWith("awgconnect://") -> urlString.removePrefix("awgconnect://")
            else -> return
        }
        try {
            appState.importFromText(payload)
        } catch (_: Exception) {
        }
    }
}

@Composable
private fun MainAppScaffold(appState: MobileAppState) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val isAddServerPresented by appState.isAddServerPresented.collectAsStateWithLifecycle()
    val pendingVpnPermission by appState.pendingVpnPermission.collectAsStateWithLifecycle()
    val context = LocalContext.current

    // System VPN consent dialog (VpnService.prepare) — launched when the state layer asks for it.
    val vpnPermissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        appState.onVpnPermissionResult(result.resultCode == Activity.RESULT_OK)
    }
    LaunchedEffect(pendingVpnPermission) {
        pendingVpnPermission?.let { vpnPermissionLauncher.launch(it) }
    }

    // Android 13+: the foreground-service notification needs runtime permission.
    val notificationPermissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { }
    LaunchedEffect(Unit) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            notificationPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
        }
        appState.connectOnLaunchIfNeeded()
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        containerColor = MaterialTheme.colorScheme.background,
        bottomBar = {
            AppNavigationBar(
                selectedTab = selectedTab,
                onTabSelected = { selectedTab = it }
            )
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            when (selectedTab) {
                0 -> DashboardScreen(
                    appState = appState,
                    onNavigateToServers = { selectedTab = 1 },
                    onOpenAddServer = { appState.setAddServerPresented(true) }
                )
                1 -> ServersScreen(
                    appState = appState,
                    onOpenAddServer = { appState.setAddServerPresented(true) }
                )
                2 -> SettingsScreen(
                    appState = appState
                )
            }

            if (isAddServerPresented) {
                AddServerBottomSheet(
                    appState = appState,
                    onDismiss = { appState.setAddServerPresented(false) }
                )
            }
        }
    }
}
