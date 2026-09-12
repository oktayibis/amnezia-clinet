package org.amnezia.mobile.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.VpnKey
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.amnezia.core.models.DnsProvider
import org.amnezia.mobile.ui.components.GlassCard
import org.amnezia.mobile.ui.theme.CyberGreen
import org.amnezia.mobile.ui.theme.DarkBackground
import org.amnezia.mobile.ui.theme.NeonCyan
import org.amnezia.mobile.ui.theme.SurfaceBorder
import org.amnezia.mobile.ui.theme.SurfaceCard
import org.amnezia.mobile.ui.theme.SurfaceDark
import org.amnezia.mobile.ui.theme.TextPrimary
import org.amnezia.mobile.ui.theme.TextSecondary
import org.amnezia.mobile.viewmodel.MobileAppState

@Composable
fun SettingsScreen(
    appState: MobileAppState,
    modifier: Modifier = Modifier
) {
    val isSimulated by appState.isSimulatedTunnel.collectAsStateWithLifecycle()
    var selectedDns by remember { mutableStateOf(DnsProvider.CLOUDFLARE) }
    var showDnsDialog by remember { mutableStateOf(false) }
    var killSwitchEnabled by remember { mutableStateOf(true) }

    val scrollState = rememberScrollState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(DarkBackground)
            .verticalScroll(scrollState)
            .padding(horizontal = 20.dp, vertical = 16.dp)
    ) {
        // Header
        Text(
            text = "Settings",
            color = TextPrimary,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(vertical = 8.dp)
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Section: Tunnel & Security
        SectionTitle(title = "TUNNEL & SECURITY")

        GlassCard {
            Column(modifier = Modifier.fillMaxWidth()) {
                // Simulation Toggle
                SettingSwitchRow(
                    icon = Icons.Default.Speed,
                    title = "Simulated Tunnel Mode",
                    subtitle = "Allows testing connection metrics and UI without root/system VPN permissions",
                    isChecked = isSimulated,
                    onCheckedChange = { appState.setSimulatedTunnel(it) }
                )

                SettingDivider()

                // Kill switch
                SettingSwitchRow(
                    icon = Icons.Default.Security,
                    title = "Kill Switch",
                    subtitle = "Block internet traffic if VPN disconnects unexpectedly",
                    isChecked = killSwitchEnabled,
                    onCheckedChange = { killSwitchEnabled = it }
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Section: Network & DNS
        SectionTitle(title = "NETWORK & DNS")

        GlassCard(onClick = { showDnsDialog = true }) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(38.dp)
                        .clip(CircleShape)
                        .background(NeonCyan.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Dns,
                        contentDescription = null,
                        tint = NeonCyan,
                        modifier = Modifier.size(20.dp)
                    )
                }

                Spacer(modifier = Modifier.width(14.dp))

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "DNS Provider",
                        color = TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        text = selectedDns.title,
                        color = TextSecondary,
                        fontSize = 13.sp
                    )
                }

                Icon(
                    imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = null,
                    tint = TextSecondary,
                    modifier = Modifier.size(20.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Section: Protocols & About
        SectionTitle(title = "ABOUT")

        GlassCard {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(text = "Client Version", color = TextSecondary, fontSize = 14.sp)
                    Text(text = "1.0.0 (Build 1)", color = TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                }

                SettingDivider(modifier = Modifier.padding(vertical = 12.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(text = "Supported Protocols", color = TextSecondary, fontSize = 14.sp)
                    Text(text = "AmneziaWG, WireGuard", color = CyberGreen, fontSize = 14.sp, fontWeight = FontWeight.SemiBold)
                }

                SettingDivider(modifier = Modifier.padding(vertical = 12.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(text = "Obfuscation Header", color = TextSecondary, fontSize = 14.sp)
                    Text(text = "Jc, Jmin, Jmax, S1, S2, H1-4", color = TextPrimary, fontSize = 13.sp)
                }
            }
        }

        Spacer(modifier = Modifier.height(30.dp))
    }

    // DNS Selection Dialog
    if (showDnsDialog) {
        AlertDialog(
            onDismissRequest = { showDnsDialog = false },
            containerColor = SurfaceDark,
            title = {
                Text(text = "Select DNS Provider", color = TextPrimary, fontWeight = FontWeight.Bold)
            },
            text = {
                Column {
                    DnsProvider.entries.forEach { provider ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(8.dp))
                                .clickable {
                                    selectedDns = provider
                                    showDnsDialog = false
                                }
                                .padding(vertical = 10.dp, horizontal = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = provider.title,
                                    color = if (selectedDns == provider) CyberGreen else TextPrimary,
                                    fontWeight = if (selectedDns == provider) FontWeight.Bold else FontWeight.Normal,
                                    fontSize = 15.sp
                                )
                                Text(
                                    text = provider.subtitle,
                                    color = TextSecondary,
                                    fontSize = 12.sp
                                )
                            }
                            if (selectedDns == provider) {
                                Icon(
                                    imageVector = Icons.Default.Check,
                                    contentDescription = null,
                                    tint = CyberGreen,
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                        }
                    }
                }
            },
            confirmButton = {
                TextButton(onClick = { showDnsDialog = false }) {
                    Text("Close", color = TextSecondary)
                }
            }
        )
    }
}

@Composable
private fun SectionTitle(title: String) {
    Text(
        text = title,
        color = TextSecondary,
        fontSize = 11.sp,
        fontWeight = FontWeight.Bold,
        letterSpacing = 1.2.sp,
        modifier = Modifier.padding(start = 4.dp, bottom = 8.dp)
    )
}

@Composable
private fun SettingSwitchRow(
    icon: ImageVector,
    title: String,
    subtitle: String,
    isChecked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(38.dp)
                .clip(CircleShape)
                .background(CyberGreen.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = CyberGreen,
                modifier = Modifier.size(20.dp)
            )
        }

        Spacer(modifier = Modifier.width(14.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                color = TextPrimary,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold
            )
            Text(
                text = subtitle,
                color = TextSecondary,
                fontSize = 12.sp
            )
        }

        Spacer(modifier = Modifier.width(10.dp))

        Switch(
            checked = isChecked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = DarkBackground,
                checkedTrackColor = CyberGreen,
                uncheckedThumbColor = TextSecondary,
                uncheckedTrackColor = SurfaceDark
            )
        )
    }
}

@Composable
private fun SettingDivider(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(1.dp)
            .background(SurfaceBorder)
    )
}
