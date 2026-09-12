package org.amnezia.mobile.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.NetworkCheck
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.amnezia.core.models.ConnectionStats
import org.amnezia.mobile.ui.theme.CyberGreen
import org.amnezia.mobile.ui.theme.NeonCyan
import org.amnezia.mobile.ui.theme.TextPrimary
import org.amnezia.mobile.ui.theme.TextSecondary

@Composable
fun LiveTrafficStatsView(
    stats: ConnectionStats,
    modifier: Modifier = Modifier
) {
    GlassCard(modifier = modifier) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 16.dp, horizontal = 12.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Ping / Latency
            StatTile(
                icon = Icons.Default.NetworkCheck,
                label = "PING",
                value = stats.latencyMs?.let { "${it}ms" } ?: "--",
                accentColor = CyberGreen
            )

            // Download
            StatTile(
                icon = Icons.Default.ArrowDownward,
                label = "DOWN",
                value = stats.formattedDownloadSpeed,
                accentColor = CyberGreen
            )

            // Upload
            StatTile(
                icon = Icons.Default.ArrowUpward,
                label = "UP",
                value = stats.formattedUploadSpeed,
                accentColor = NeonCyan
            )

            // Duration
            StatTile(
                icon = Icons.Default.Timer,
                label = "TIME",
                value = stats.formattedDuration,
                accentColor = TextSecondary
            )
        }
    }
}

@Composable
private fun StatTile(
    icon: ImageVector,
    label: String,
    value: String,
    accentColor: androidx.compose.ui.graphics.Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = accentColor,
                modifier = Modifier.size(13.dp)
            )
            Text(
                text = " $label",
                color = TextSecondary,
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = value,
            color = TextPrimary,
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold
        )
    }
}
