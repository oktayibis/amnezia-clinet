package org.amnezia.tv

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.focusable
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.PowerSettingsNew
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.amnezia.tv.ui.screens.TvDashboardScreen
import org.amnezia.tv.ui.screens.TvServersScreen
import org.amnezia.tv.ui.screens.TvSettingsScreen
import org.amnezia.tv.ui.theme.AmneziaTvTheme
import org.amnezia.tv.ui.theme.CyberGreen
import org.amnezia.tv.ui.theme.DarkBackground
import org.amnezia.tv.ui.theme.SurfaceBorder
import org.amnezia.tv.ui.theme.SurfaceCard
import org.amnezia.tv.ui.theme.TextPrimary
import org.amnezia.tv.ui.theme.TextSecondary
import org.amnezia.tv.viewmodel.TvAppState

class TvMainActivity : ComponentActivity() {

    private lateinit var appState: TvAppState

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        appState = (application as AmneziaTvApp).appState

        setContent {
            AmneziaTvTheme {
                TvAppScaffold(appState = appState)
            }
        }
    }
}

private enum class TvTab(val title: String, val icon: ImageVector) {
    DASHBOARD("CONNECT", Icons.Default.PowerSettingsNew),
    SERVERS("SERVERS", Icons.Default.Dns),
    SETTINGS("SETTINGS", Icons.Default.Settings)
}

@Composable
private fun TvAppScaffold(appState: TvAppState) {
    var selectedTab by remember { mutableIntStateOf(0) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
    ) {
        // Top TV Header Bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(SurfaceCard.copy(alpha = 0.5f))
                .border(width = 1.dp, color = SurfaceBorder)
                .padding(horizontal = 48.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Brand Title
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "AMNEZIA",
                    color = CyberGreen,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Black,
                    letterSpacing = 2.sp
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "TV",
                    color = TextPrimary,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Light,
                    letterSpacing = 1.sp
                )
            }

            // Top Navigation Tabs
            Row(
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                TvTab.entries.forEachIndexed { index, tab ->
                    TvNavTabButton(
                        tab = tab,
                        isSelected = selectedTab == index,
                        onClick = { selectedTab = index }
                    )
                }
            }
        }

        // Content Body
        Box(
            modifier = Modifier
                .fillMaxSize()
                .weight(1f)
        ) {
            when (selectedTab) {
                0 -> TvDashboardScreen(
                    appState = appState,
                    onNavigateToServers = { selectedTab = 1 }
                )
                1 -> TvServersScreen(appState = appState)
                2 -> TvSettingsScreen(appState = appState)
            }
        }
    }
}

@Composable
private fun TvNavTabButton(
    tab: TvTab,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    var isFocused by remember { mutableStateOf(false) }

    val backgroundColor by animateColorAsState(
        targetValue = when {
            isFocused -> CyberGreen
            isSelected -> Color(0x33FFFFFF)
            else -> Color.Transparent
        },
        label = "tabBg"
    )

    val contentColor by animateColorAsState(
        targetValue = when {
            isFocused -> DarkBackground
            isSelected -> CyberGreen
            else -> TextSecondary
        },
        label = "tabContent"
    )

    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .background(backgroundColor)
            .border(
                width = if (isFocused) 2.dp else if (isSelected) 1.dp else 0.dp,
                color = if (isFocused) Color.White else if (isSelected) CyberGreen else Color.Transparent,
                shape = RoundedCornerShape(8.dp)
            )
            .onFocusChanged {
                isFocused = it.isFocused
                if (it.isFocused) {
                    onClick()
                }
            }
            .focusable()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = tab.icon,
            contentDescription = null,
            tint = contentColor,
            modifier = Modifier.size(18.dp)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = tab.title,
            color = contentColor,
            fontSize = 13.sp,
            fontWeight = if (isFocused || isSelected) FontWeight.Bold else FontWeight.Medium,
            letterSpacing = 1.sp
        )
    }
}
