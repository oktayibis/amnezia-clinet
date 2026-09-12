package org.amnezia.mobile.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
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
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.ContentPaste
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.amnezia.mobile.ui.components.ConnectButton
import org.amnezia.mobile.ui.components.ConnectionStatusCard
import org.amnezia.mobile.ui.components.GlassCard
import org.amnezia.mobile.ui.components.LiveTrafficStatsView
import org.amnezia.mobile.ui.components.StatusPill
import org.amnezia.mobile.ui.theme.ConnectingOrange
import org.amnezia.mobile.ui.theme.CyberGreen
import org.amnezia.mobile.ui.theme.DarkBackground
import org.amnezia.mobile.ui.theme.ErrorRed
import org.amnezia.mobile.ui.theme.SurfaceCard
import org.amnezia.mobile.ui.theme.TextPrimary
import org.amnezia.mobile.ui.theme.TextSecondary
import org.amnezia.mobile.viewmodel.MobileAppState

@Composable
fun DashboardScreen(
    appState: MobileAppState,
    onNavigateToServers: () -> Unit,
    onOpenAddServer: () -> Unit,
    modifier: Modifier = Modifier
) {
    val connectionState by appState.connectionState.collectAsStateWithLifecycle()
    val selectedProfile by appState.selectedProfile.collectAsStateWithLifecycle()
    val stats by appState.stats.collectAsStateWithLifecycle()
    val detectedClipboardUrl by appState.detectedClipboardUrl.collectAsStateWithLifecycle()
    val errorMessage by appState.errorMessage.collectAsStateWithLifecycle()
    val isSimulated by appState.isSimulatedTunnel.collectAsStateWithLifecycle()

    val scrollState = rememberScrollState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(DarkBackground)
            .verticalScroll(scrollState)
            .padding(horizontal = 20.dp, vertical = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Top Bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "AMNEZIA",
                    color = TextPrimary,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 2.sp
                )
                if (isSimulated) {
                    Spacer(modifier = Modifier.width(10.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(ConnectingOrange.copy(alpha = 0.15f))
                            .border(1.dp, ConnectingOrange.copy(alpha = 0.3f), RoundedCornerShape(6.dp))
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = "SIMULATED",
                            color = ConnectingOrange,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            IconButton(
                onClick = onOpenAddServer,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(SurfaceCard)
                    .size(40.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = "Add Server",
                    tint = CyberGreen,
                    modifier = Modifier.size(20.dp)
                )
            }
        }

        // Clipboard auto-detection banner
        AnimatedVisibility(
            visible = detectedClipboardUrl != null,
            enter = fadeIn(),
            exit = fadeOut()
        ) {
            detectedClipboardUrl?.let { url ->
                Spacer(modifier = Modifier.height(8.dp))
                GlassCard(
                    borderColor = CyberGreen.copy(alpha = 0.5f),
                    backgroundColor = CyberGreen.copy(alpha = 0.08f)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.ContentPaste,
                            contentDescription = null,
                            tint = CyberGreen,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "Config in Clipboard",
                                color = TextPrimary,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = "Tap import to configure this server",
                                color = TextSecondary,
                                fontSize = 11.sp
                            )
                        }
                        Button(
                            onClick = {
                                try {
                                    appState.importFromText(url)
                                } catch (_: Exception) { }
                            },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = CyberGreen,
                                contentColor = DarkBackground
                            ),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.height(34.dp)
                        ) {
                            Text("Import", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        }
                        Spacer(modifier = Modifier.width(6.dp))
                        IconButton(
                            onClick = { appState.dismissClipboardBanner() },
                            modifier = Modifier.size(28.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Close,
                                contentDescription = "Dismiss",
                                tint = TextSecondary,
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }
                }
            }
        }

        // Error message banner
        AnimatedVisibility(
            visible = errorMessage != null,
            enter = fadeIn(),
            exit = fadeOut()
        ) {
            errorMessage?.let { error ->
                Spacer(modifier = Modifier.height(8.dp))
                GlassCard(
                    borderColor = ErrorRed.copy(alpha = 0.5f),
                    backgroundColor = ErrorRed.copy(alpha = 0.08f)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.ErrorOutline,
                            contentDescription = null,
                            tint = ErrorRed,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(
                            text = error,
                            color = TextPrimary,
                            fontSize = 12.sp,
                            modifier = Modifier.weight(1f)
                        )
                        IconButton(
                            onClick = { appState.clearErrorMessage() },
                            modifier = Modifier.size(28.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Close,
                                contentDescription = "Dismiss",
                                tint = TextSecondary,
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(28.dp))

        // Hero Section: Status & Connect Button
        StatusPill(state = connectionState)

        Spacer(modifier = Modifier.height(32.dp))

        ConnectButton(
            connectionState = connectionState,
            onClick = { appState.toggleConnection() }
        )

        Spacer(modifier = Modifier.height(18.dp))

        Text(
            text = when {
                connectionState.isConnected -> "Connection Encrypted"
                connectionState.isBusy -> "Establishing Tunnel..."
                else -> "Tap power button to connect"
            },
            color = TextSecondary,
            fontSize = 13.sp,
            fontWeight = FontWeight.Medium
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Live Traffic Metrics Card
        LiveTrafficStatsView(stats = stats)

        Spacer(modifier = Modifier.height(16.dp))

        // Selected Server Card
        ConnectionStatusCard(
            profile = selectedProfile,
            onClick = onNavigateToServers
        )

        Spacer(modifier = Modifier.height(24.dp))
    }
}
