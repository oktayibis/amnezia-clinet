package org.amnezia.tv.ui.screens

import android.content.Intent
import android.provider.Settings
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material3.Icon
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.amnezia.core.models.DnsProvider
import org.amnezia.tv.BuildConfig
import org.amnezia.tv.ui.components.TvFocusableCard
import org.amnezia.tv.ui.theme.CyberGreen
import org.amnezia.tv.ui.theme.DarkBackground
import org.amnezia.tv.ui.theme.SurfaceBorder
import org.amnezia.tv.ui.theme.SurfaceCard
import org.amnezia.tv.ui.theme.TextPrimary
import org.amnezia.tv.ui.theme.TextSecondary
import org.amnezia.tv.viewmodel.TvAppState

@Composable
fun TvSettingsScreen(
    appState: TvAppState,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val settings = appState.settings
    val isSimulated by appState.isSimulatedTunnel.collectAsStateWithLifecycle()
    var selectedDns by remember { mutableStateOf(settings.dnsProvider) }
    var connectOnLaunch by remember { mutableStateOf(settings.connectOnLaunch) }
    val scrollState = rememberScrollState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(DarkBackground)
            .verticalScroll(scrollState)
            .padding(horizontal = 48.dp, vertical = 20.dp)
    ) {
        Text(
            text = "SETTINGS",
            color = TextPrimary,
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.2.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        SectionLabel("TUNNEL & SECURITY")

        TvFocusableCard(
            onClick = {
                connectOnLaunch = !connectOnLaunch
                settings.connectOnLaunch = connectOnLaunch
            },
            modifier = Modifier.padding(vertical = 4.dp)
        ) { _ ->
            SettingRow(
                icon = Icons.Default.PlayArrow,
                title = "Connect on Launch",
                subtitle = "Automatically connect to the active server when the app opens"
            ) {
                Switch(
                    checked = connectOnLaunch,
                    onCheckedChange = {
                        connectOnLaunch = it
                        settings.connectOnLaunch = it
                    },
                    colors = SwitchDefaults.colors(checkedThumbColor = DarkBackground, checkedTrackColor = CyberGreen)
                )
            }
        }

        TvFocusableCard(
            onClick = {
                runCatching { context.startActivity(Intent(Settings.ACTION_VPN_SETTINGS)) }
            },
            modifier = Modifier.padding(vertical = 4.dp)
        ) { _ ->
            SettingRow(
                icon = Icons.Default.Shield,
                title = "Always-on VPN & Kill Switch",
                subtitle = "Managed by Android: enable Always-on VPN and Block connections without VPN in system settings"
            ) { }
        }

        Spacer(modifier = Modifier.height(18.dp))

        SectionLabel("DNS PROVIDER")

        DnsProvider.entries.filter { it != DnsProvider.CUSTOM }.forEach { provider ->
            val isChosen = selectedDns == provider
            TvFocusableCard(
                onClick = {
                    selectedDns = provider
                    settings.dnsProvider = provider
                },
                defaultBorderColor = if (isChosen) CyberGreen else SurfaceBorder,
                modifier = Modifier.padding(vertical = 4.dp)
            ) { _ ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = provider.title,
                            color = if (isChosen) CyberGreen else TextPrimary,
                            fontSize = 16.sp,
                            fontWeight = if (isChosen) FontWeight.Bold else FontWeight.Medium
                        )
                        Text(text = provider.subtitle, color = TextSecondary, fontSize = 12.sp)
                    }

                    if (isChosen) {
                        Box(
                            modifier = Modifier
                                .size(24.dp)
                                .clip(CircleShape)
                                .background(CyberGreen),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(imageVector = Icons.Default.Check, contentDescription = null, tint = DarkBackground, modifier = Modifier.size(16.dp))
                        }
                    }
                }
            }
        }

        if (BuildConfig.DEBUG) {
            Spacer(modifier = Modifier.height(18.dp))
            SectionLabel("DEVELOPER (DEBUG BUILD ONLY)")
            TvFocusableCard(
                onClick = { appState.setSimulatedTunnel(!isSimulated) },
                modifier = Modifier.padding(vertical = 4.dp)
            ) { _ ->
                SettingRow(
                    icon = Icons.Default.Speed,
                    title = "Simulated Tunnel Mode",
                    subtitle = "Fake connection flow and metrics for UI testing. Not available in release builds."
                ) {
                    Switch(
                        checked = isSimulated,
                        onCheckedChange = { appState.setSimulatedTunnel(it) },
                        colors = SwitchDefaults.colors(checkedThumbColor = DarkBackground, checkedTrackColor = CyberGreen)
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        SectionLabel("PRIVACY")

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(SurfaceCard)
                .border(1.dp, SurfaceBorder, RoundedCornerShape(16.dp))
                .padding(20.dp)
        ) {
            SettingRow(
                icon = Icons.Default.Security,
                title = "No data collection",
                subtitle = "Configs never leave this device. Full policy: $TV_PRIVACY_POLICY_URL"
            ) { }
        }

        Spacer(modifier = Modifier.height(18.dp))

        SectionLabel("ABOUT")

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(SurfaceCard)
                .border(1.dp, SurfaceBorder, RoundedCornerShape(16.dp))
                .padding(20.dp)
        ) {
            Column {
                AboutRow("Client Version", "${BuildConfig.VERSION_NAME} (Build ${BuildConfig.VERSION_CODE}) for Android TV")
                Spacer(modifier = Modifier.height(12.dp))
                AboutRow("Supported Protocols", "AmneziaWG, WireGuard", CyberGreen)
                Spacer(modifier = Modifier.height(12.dp))
                AboutRow("Open Source (MIT)", "github.com/oktayibis/amnezia-clinet")
            }
        }

        Spacer(modifier = Modifier.height(30.dp))
    }
}

@Composable
private fun SectionLabel(text: String) {
    Text(
        text = text,
        color = TextSecondary,
        fontSize = 12.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = 1.2.sp,
        modifier = Modifier.padding(start = 4.dp, bottom = 8.dp)
    )
}

@Composable
private fun AboutRow(label: String, value: String, valueColor: Color = TextPrimary) {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(label, color = TextSecondary, fontSize = 14.sp)
        Text(value, color = valueColor, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun SettingRow(
    icon: ImageVector,
    title: String,
    subtitle: String,
    trailing: @Composable () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(20.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(CyberGreen.copy(alpha = 0.2f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = icon, contentDescription = null, tint = CyberGreen, modifier = Modifier.size(24.dp))
        }
        Spacer(modifier = Modifier.width(16.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(text = title, color = TextPrimary, fontSize = 17.sp, fontWeight = FontWeight.SemiBold)
            Text(text = subtitle, color = TextSecondary, fontSize = 13.sp)
        }
        trailing()
    }
}
