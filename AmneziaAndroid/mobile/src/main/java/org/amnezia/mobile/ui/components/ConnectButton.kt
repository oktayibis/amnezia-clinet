package org.amnezia.mobile.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
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
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PowerSettingsNew
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import org.amnezia.core.models.ConnectionState

@Composable
fun ConnectButton(
    connectionState: ConnectionState,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isConnected = connectionState.isConnected
    val isBusy = connectionState.isBusy

    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()

    // Tactile press scale
    val pressScale by animateFloatAsState(
        targetValue = if (isPressed) 0.94f else 1.0f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "pressScale"
    )

    // Infinite breathing/pulsing animation
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
        targetValue = 0.45f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "haloAlpha"
    )

    // M3 Color roles
    val containerColor by animateColorAsState(
        targetValue = when {
            isConnected -> MaterialTheme.colorScheme.primary
            isBusy -> MaterialTheme.colorScheme.tertiaryContainer
            else -> MaterialTheme.colorScheme.surfaceContainerHigh
        },
        animationSpec = tween(350),
        label = "btnColor"
    )

    val iconColor by animateColorAsState(
        targetValue = when {
            isConnected -> MaterialTheme.colorScheme.onPrimary
            isBusy -> MaterialTheme.colorScheme.onTertiaryContainer
            else -> MaterialTheme.colorScheme.primary
        },
        animationSpec = tween(300),
        label = "iconColor"
    )

    Box(
        modifier = modifier
            .size(200.dp)
            .scale(pressScale),
        contentAlignment = Alignment.Center
    ) {
        // Layer 1: Ambient M3 aura when connecting or connected
        if (isConnected || isBusy) {
            val auraColor = if (isConnected) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.tertiaryContainer
            }
            Box(
                modifier = Modifier
                    .size(195.dp)
                    .scale(haloPulse)
                    .clip(CircleShape)
                    .background(auraColor.copy(alpha = haloAlpha))
            )
        }

        // Layer 2: Outer M3 track ring
        Box(
            modifier = Modifier
                .size(180.dp)
                .clip(CircleShape)
                .border(
                    width = 2.dp,
                    color = if (isConnected || isBusy) {
                        containerColor.copy(alpha = 0.4f)
                    } else {
                        MaterialTheme.colorScheme.surfaceContainerHighest
                    },
                    shape = CircleShape
                )
        )

        // Layer 3: Main M3 Surface button
        Surface(
            onClick = onClick,
            modifier = Modifier.size(148.dp),
            shape = CircleShape,
            color = containerColor,
            tonalElevation = if (isConnected) 8.dp else 4.dp,
            shadowElevation = if (isConnected) 12.dp else 4.dp,
            interactionSource = interactionSource
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.size(148.dp)
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
}

