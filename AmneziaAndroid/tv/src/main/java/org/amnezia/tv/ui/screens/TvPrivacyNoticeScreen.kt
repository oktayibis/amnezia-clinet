package org.amnezia.tv.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.SwapHoriz
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.amnezia.tv.ui.theme.CyberGreen
import org.amnezia.tv.ui.theme.DarkBackground
import org.amnezia.tv.ui.theme.SurfaceCard
import org.amnezia.tv.ui.theme.TextPrimary
import org.amnezia.tv.ui.theme.TextSecondary

const val TV_PRIVACY_POLICY_URL = "https://github.com/oktayibis/amnezia-clinet/blob/main/PRIVACY.md"

/** First-launch VpnService disclosure for Android TV (D-pad friendly, single focus target). */
@Composable
fun TvPrivacyNoticeScreen(onAccept: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
            .padding(horizontal = 96.dp, vertical = 40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(imageVector = Icons.Default.Security, contentDescription = null, tint = CyberGreen, modifier = Modifier.size(56.dp))
        Spacer(modifier = Modifier.height(16.dp))
        Text(text = "Your Privacy Comes First", color = TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "AWG Connect TV is an independent, open-source client for your own WireGuard and AmneziaWG servers.",
            color = TextSecondary,
            fontSize = 16.sp,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(28.dp))

        Column(
            modifier = Modifier
                .widthIn(max = 760.dp)
                .background(SurfaceCard, RoundedCornerShape(16.dp))
                .padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Bullet(Icons.Default.VisibilityOff, "Zero data collection", "No analytics, no accounts, no logs of your browsing, DNS queries or device.")
            Bullet(Icons.Default.Lock, "Configs stay on this device", "Server addresses and keys are stored locally and never uploaded anywhere.")
            Bullet(Icons.Default.SwapHoriz, "Traffic goes to your server only", "While connected, all traffic is routed to the VPN server you imported. The developer runs no servers.")
        }

        Spacer(modifier = Modifier.height(12.dp))
        Text(text = "Full policy: $TV_PRIVACY_POLICY_URL", color = TextSecondary, fontSize = 12.sp)
        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick = onAccept,
            modifier = Modifier
                .widthIn(min = 320.dp)
                .height(56.dp),
            colors = ButtonDefaults.buttonColors(containerColor = CyberGreen, contentColor = DarkBackground),
            shape = RoundedCornerShape(14.dp)
        ) {
            Text("I Understand & Agree", fontWeight = FontWeight.Bold, fontSize = 18.sp)
        }
    }
}

@Composable
private fun Bullet(icon: ImageVector, title: String, text: String) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.Top) {
        Icon(imageVector = icon, contentDescription = null, tint = CyberGreen, modifier = Modifier.size(24.dp))
        Spacer(modifier = Modifier.width(14.dp))
        Column {
            Text(text = title, color = TextPrimary, fontSize = 17.sp, fontWeight = FontWeight.SemiBold)
            Text(text = text, color = TextSecondary, fontSize = 14.sp)
        }
    }
}
