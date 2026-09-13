package org.amnezia.mobile.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedCard
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Material 3 Card adhering to m3.material.io specifications:
 * 16dp corner radius, surfaceContainerLow background, outlineVariant border.
 */
@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(16.dp),
    backgroundColor: Color = MaterialTheme.colorScheme.surfaceContainerLow,
    borderColor: Color = MaterialTheme.colorScheme.outlineVariant,
    borderWidth: Dp = 1.dp,
    onClick: (() -> Unit)? = null,
    content: @Composable BoxScope.() -> Unit
) {
    if (onClick != null) {
        OutlinedCard(
            onClick = onClick,
            modifier = modifier.fillMaxWidth(),
            shape = shape,
            colors = CardDefaults.outlinedCardColors(
                containerColor = backgroundColor
            ),
            border = BorderStroke(borderWidth, borderColor)
        ) {
            Box { content() }
        }
    } else {
        OutlinedCard(
            modifier = modifier.fillMaxWidth(),
            shape = shape,
            colors = CardDefaults.outlinedCardColors(
                containerColor = backgroundColor
            ),
            border = BorderStroke(borderWidth, borderColor)
        ) {
            Box { content() }
        }
    }
}

