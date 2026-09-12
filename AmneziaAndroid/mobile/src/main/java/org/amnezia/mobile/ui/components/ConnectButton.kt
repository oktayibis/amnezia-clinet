package org.amnezia.mobile.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PowerSettingsNew
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import org.amnezia.core.models.ConnectionState
import org.amnezia.mobile.ui.theme.ConnectingOrange
import org.amnezia.mobile.ui.theme.CyberGreen
import org.amnezia.mobile.ui.theme.DarkBackground
import org.amnezia.mobile.ui.theme.SurfaceCard
import org.amnezia.mobile.ui.theme.TextPrimary
import org.amnezia.mobile.ui.theme.TextSecondary

@Composable
fun ConnectButton(
    connectionState: ConnectionState,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isConnected = connectionState.isConnected
    val isBusy = connectionState.isBusy

    val infiniteTransition = rememberInfiniteTransition(label = "halo")
    val haloPulse by infiniteTransition.animateFloat(
        initialValue = 1.0f,
        targetValue = 1.15f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "haloScale"
    )
    val haloAlpha by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = 0.5f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "haloAlpha"
    )

    val buttonColor by animateColorAsState(
        targetValue = when {
            isConnected -> CyberGreen
            isBusy -> ConnectingOrange
            else -> SurfaceCard
        },
        animationSpec = tween(500),
        label = "btnColor"
    )

    val iconColor by animateColorAsState(
        targetValue = when {
            isConnected -> DarkBackground
            isBusy -> DarkBackground
            else -> CyberGreen
        },
        animationSpec = tween(300),
        label = "iconColor"
    )

    Box(
        modifier = modifier.size(190.dp),
        contentAlignment = Alignment.Center
    ) {
        // Outer glowing halo (visible when connected or busy)
        if (isConnected || isBusy) {
            Box(
                modifier = Modifier
                    .size(175.dp)
                    .scale(haloPulse)
                    .clip(CircleShape)
                    .background(
                        Brush.radialGradient(
                            colors = listOf(
                                buttonColor.copy(alpha = haloAlpha),
                                Color.Transparent
                            )
                        )
                    )
            )
        }

        // Secondary border ring
        Box(
            modifier = Modifier
                .size(164.dp)
                .clip(CircleShape)
                .border(
                    width = 2.dp,
                    color = if (isConnected || isBusy) buttonColor.copy(alpha = 0.6f) else Color(0x22FFFFFF),
                    shape = CircleShape
                )
        )

        // Main inner circular button
        Box(
            modifier = Modifier
                .size(142.dp)
                .clip(CircleShape)
                .background(
                    if (isConnected || isBusy) {
                        Brush.verticalGradient(
                            listOf(
                                buttonColor,
                                buttonColor.copy(alpha = 0.85f)
                            )
                        )
                    } else {
                        Brush.verticalGradient(
                            listOf(
                                Color(0xFF1E2638),
                                Color(0xFF141A26)
                            )
                        )
                    }
                )
                .border(
                    width = 1.5.dp,
                    color = if (isConnected || isBusy) Color.White.copy(alpha = 0.3f) else Color(0x33FFFFFF),
                    shape = CircleShape
                )
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onClick
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.PowerSettingsNew,
                contentDescription = if (isConnected) "Disconnect" else "Connect",
                tint = iconColor,
                modifier = Modifier.size(54.dp)
            )
        }
    }
}
