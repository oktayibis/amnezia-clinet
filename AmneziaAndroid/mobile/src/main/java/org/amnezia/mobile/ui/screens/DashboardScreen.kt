@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package org.amnezia.mobile.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.ContentPaste
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.AssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SuggestionChip
import androidx.compose.material3.SuggestionChipDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.amnezia.mobile.BuildConfig
import org.amnezia.mobile.ui.components.ConnectButton
import org.amnezia.mobile.ui.components.ConnectionStatusCard
import org.amnezia.mobile.ui.components.LiveTrafficStatsView
import org.amnezia.mobile.ui.components.StatusPill
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
    val errorMessage by appState.errorMessage.collectAsStateWithLifecycle()
    val isSimulated by appState.isSimulatedTunnel.collectAsStateWithLifecycle()
    val providesTrafficStats by appState.providesTrafficStats.collectAsStateWithLifecycle()

    val scrollState = rememberScrollState()

    BoxWithConstraints(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        val screenHeight = maxHeight

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(scrollState)
                .heightIn(min = screenHeight)
                .padding(horizontal = 20.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.SpaceBetween,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Section 1: Official Material 3 Top App Bar
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                CenterAlignedTopAppBar(
                    title = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = "AWG Connect",
                                style = MaterialTheme.typography.titleLarge,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                            if (BuildConfig.DEBUG && isSimulated) {
                                Spacer(modifier = Modifier.width(8.dp))
                                SuggestionChip(
                                    onClick = {},
                                    label = {
                                        Text(
                                            text = "Simulated",
                                            style = MaterialTheme.typography.labelSmall
                                        )
                                    },
                                    colors = SuggestionChipDefaults.suggestionChipColors(
                                        containerColor = MaterialTheme.colorScheme.tertiaryContainer,
                                        labelColor = MaterialTheme.colorScheme.onTertiaryContainer
                                    ),
                                    border = null
                                )
                            }
                        }
                    },
                    actions = {
                        IconButton(onClick = { appState.importFromClipboard() }) {
                            Icon(
                                imageVector = Icons.Default.ContentPaste,
                                contentDescription = "Import from clipboard",
                                tint = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                        IconButton(onClick = onOpenAddServer) {
                            Icon(
                                imageVector = Icons.Default.Add,
                                contentDescription = "Add server",
                                tint = MaterialTheme.colorScheme.primary
                            )
                        }
                    },
                    colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                        containerColor = MaterialTheme.colorScheme.background
                    )
                )

                // Error message banner using M3 ErrorContainer
                AnimatedVisibility(
                    visible = errorMessage != null,
                    enter = fadeIn(),
                    exit = fadeOut()
                ) {
                    errorMessage?.let { error ->
                        Spacer(modifier = Modifier.height(4.dp))
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(12.dp),
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.errorContainer,
                                contentColor = MaterialTheme.colorScheme.onErrorContainer
                            )
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
                                    tint = MaterialTheme.colorScheme.error,
                                    modifier = Modifier.size(20.dp)
                                )
                                Spacer(modifier = Modifier.width(10.dp))
                                Text(
                                    text = error,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onErrorContainer,
                                    modifier = Modifier.weight(1f)
                                )
                                IconButton(
                                    onClick = { appState.clearErrorMessage() },
                                    modifier = Modifier.size(28.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Close,
                                        contentDescription = "Dismiss",
                                        tint = MaterialTheme.colorScheme.onErrorContainer,
                                        modifier = Modifier.size(16.dp)
                                    )
                                }
                            }
                        }
                    }
                }
            }

            // Section 2: Center Hero Area (StatusPill + ConnectButton + Subtitle)
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                StatusPill(state = connectionState)

                Spacer(modifier = Modifier.height(28.dp))

                ConnectButton(
                    connectionState = connectionState,
                    onClick = { appState.toggleConnection() }
                )

                Spacer(modifier = Modifier.height(20.dp))

                Text(
                    text = when {
                        connectionState.isConnected -> "Tunnel is active & secured"
                        connectionState.isBusy -> "Establishing tunnel..."
                        else -> "Tap power button to connect"
                    },
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // Section 3: Bottom Section (Security telemetry chips + Traffic Stats + Server Card)
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Live traffic meters
                if (providesTrafficStats) {
                    LiveTrafficStatsView(stats = stats)
                    Spacer(modifier = Modifier.height(14.dp))
                }

                // Official M3 AssistChips for security features
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 12.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally)
                ) {
                    M3SecurityChip(icon = Icons.Default.Shield, label = "Zero logs")
                    M3SecurityChip(icon = Icons.Default.Bolt, label = "AmneziaWG")
                    M3SecurityChip(icon = Icons.Default.Dns, label = "Private DNS")
                }

                // Selected Server Card
                ConnectionStatusCard(
                    profile = selectedProfile,
                    onClick = onNavigateToServers
                )

                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }
}

/**
 * Official Material 3 AssistChip for security indicators
 */
@Composable
private fun M3SecurityChip(
    icon: ImageVector,
    label: String,
    modifier: Modifier = Modifier
) {
    AssistChip(
        onClick = {},
        label = {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        },
        leadingIcon = {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(16.dp)
            )
        },
        colors = AssistChipDefaults.assistChipColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerLow
        ),
        border = AssistChipDefaults.assistChipBorder(
            enabled = true,
            borderColor = MaterialTheme.colorScheme.outlineVariant
        ),
        modifier = modifier
    )
}

