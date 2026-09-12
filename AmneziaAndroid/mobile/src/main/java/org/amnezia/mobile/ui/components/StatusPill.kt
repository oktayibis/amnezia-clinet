package org.amnezia.mobile.ui.components

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.amnezia.core.models.ConnectionState
import org.amnezia.mobile.ui.theme.ConnectingOrange
import org.amnezia.mobile.ui.theme.CyberGreen
import org.amnezia.mobile.ui.theme.ErrorRed
import org.amnezia.mobile.ui.theme.TextSecondary

@Composable
fun StatusPill(
    state: ConnectionState,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "pulse")
    val pulseAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 1.0f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 800, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulseAlpha"
    )

    val (statusColor, statusText, isPulsing) = when (state) {
        is ConnectionState.Connected -> Triple(CyberGreen, "CONNECTED", false)
        is ConnectionState.Connecting -> Triple(ConnectingOrange, "CONNECTING...", true)
        is ConnectionState.Reconnecting -> Triple(ConnectingOrange, "RECONNECTING...", true)
        is ConnectionState.Disconnecting -> Triple(ConnectingOrange, "DISCONNECTING...", true)
        is ConnectionState.Error -> Triple(ErrorRed, "ERROR", false)
        is ConnectionState.Disconnected -> Triple(TextSecondary, "DISCONNECTED", false)
    }

    Row(
        modifier = modifier
            .clip(RoundedCornerShape(50.dp))
            .background(statusColor.copy(alpha = 0.12f))
            .border(1.dp, statusColor.copy(alpha = 0.25f), RoundedCornerShape(50.dp))
            .padding(horizontal = 14.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .then(if (isPulsing) Modifier.alpha(pulseAlpha) else Modifier)
                .clip(CircleShape)
                .background(statusColor)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = statusText,
            color = statusColor,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.2.sp
        )
    }
}
