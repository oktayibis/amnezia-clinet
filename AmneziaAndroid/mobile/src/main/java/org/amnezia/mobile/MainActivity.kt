package org.amnezia.mobile

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.PowerSettingsNew
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.amnezia.mobile.ui.screens.AddServerBottomSheet
import org.amnezia.mobile.ui.screens.DashboardScreen
import org.amnezia.mobile.ui.screens.ServersScreen
import org.amnezia.mobile.ui.screens.SettingsScreen
import org.amnezia.mobile.ui.theme.AmneziaTheme
import org.amnezia.mobile.ui.theme.CyberGreen
import org.amnezia.mobile.ui.theme.DarkBackground
import org.amnezia.mobile.ui.theme.SurfaceBorder
import org.amnezia.mobile.ui.theme.SurfaceDark
import org.amnezia.mobile.ui.theme.TextPrimary
import org.amnezia.mobile.ui.theme.TextSecondary
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
                MainAppScaffold(appState = appState)
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        appState.checkClipboard()
    }

    private fun handleIntent(intent: Intent?) {
        val uri = intent?.data ?: return
        val urlString = uri.toString()
        if (urlString.startsWith("vpn://") || urlString.startsWith("amnezia://")) {
            try {
                appState.importFromText(urlString)
            } catch (_: Exception) { }
        }
    }
}

private enum class NavTab(val title: String, val icon: ImageVector) {
    CONNECT("Connect", Icons.Default.PowerSettingsNew),
    SERVERS("Servers", Icons.Default.Dns),
    SETTINGS("Settings", Icons.Default.Settings)
}

@Composable
private fun MainAppScaffold(appState: MobileAppState) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val isAddServerPresented by appState.isAddServerPresented.collectAsStateWithLifecycle()

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        containerColor = DarkBackground,
        bottomBar = {
            Box(
                modifier = Modifier
                    .background(SurfaceDark)
                    .border(width = 1.dp, color = SurfaceBorder)
            ) {
                NavigationBar(
                    containerColor = SurfaceDark,
                    tonalElevation = 0.dp,
                    modifier = Modifier.height(72.dp)
                ) {
                    NavTab.entries.forEachIndexed { index, tab ->
                        val isSelected = selectedTab == index
                        NavigationBarItem(
                            selected = isSelected,
                            onClick = { selectedTab = index },
                            icon = {
                                Icon(
                                    imageVector = tab.icon,
                                    contentDescription = tab.title,
                                    modifier = Modifier.size(22.dp)
                                )
                            },
                            label = {
                                Text(
                                    text = tab.title,
                                    fontSize = 12.sp,
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                                )
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = CyberGreen,
                                selectedTextColor = CyberGreen,
                                unselectedIconColor = TextSecondary,
                                unselectedTextColor = TextSecondary,
                                indicatorColor = Color.Transparent
                            )
                        )
                    }
                }
            }
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
