package org.amnezia.mobile.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColorScheme = darkColorScheme(
    primary = M3Primary,
    onPrimary = M3OnPrimary,
    primaryContainer = M3PrimaryContainer,
    onPrimaryContainer = M3OnPrimaryContainer,
    secondary = M3Secondary,
    onSecondary = M3OnSecondary,
    secondaryContainer = M3SecondaryContainer,
    onSecondaryContainer = M3OnSecondaryContainer,
    tertiary = M3Tertiary,
    onTertiary = M3OnTertiary,
    tertiaryContainer = M3TertiaryContainer,
    onTertiaryContainer = M3OnTertiaryContainer,
    background = M3Background,
    onBackground = M3OnBackground,
    surface = M3Surface,
    onSurface = M3OnSurface,
    surfaceVariant = M3SurfaceVariant,
    onSurfaceVariant = M3OnSurfaceVariant,
    surfaceContainerLowest = M3SurfaceContainerLowest,
    surfaceContainerLow = M3SurfaceContainerLow,
    surfaceContainer = M3SurfaceContainer,
    surfaceContainerHigh = M3SurfaceContainerHigh,
    surfaceContainerHighest = M3SurfaceContainerHighest,
    outline = M3Outline,
    outlineVariant = M3OutlineVariant,
    error = M3Error,
    onError = M3OnError,
    errorContainer = M3ErrorContainer,
    onErrorContainer = M3OnErrorContainer
)

@Composable
fun AmneziaTheme(
    darkTheme: Boolean = true, // We enforce the sleek obsidian theme
    content: @Composable () -> Unit
) {
    val colorScheme = DarkColorScheme
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as? Activity)?.window
            if (window != null) {
                window.statusBarColor = DarkBackground.toArgb()
                window.navigationBarColor = DarkBackground.toArgb()
                WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
                WindowCompat.getInsetsController(window, view).isAppearanceLightNavigationBars = false
            }
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
