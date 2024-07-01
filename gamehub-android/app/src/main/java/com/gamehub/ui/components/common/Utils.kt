package com.gamehub.ui.components.common

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.gamehub.ui.theme.LightGray

@Composable
fun DashedDivider(
    thickness: Dp,
    color: Color = MaterialTheme.colorScheme.onSurfaceVariant,
    phase: Float = 10f,
    intervals: FloatArray = floatArrayOf(10f, 10f),
    modifier: Modifier
) {
    Canvas(
        modifier = modifier
    ) {
        val dividerHeight = thickness.toPx()
        drawRoundRect(
            color = color,
            style = Stroke(
                width = dividerHeight,
                pathEffect = PathEffect.dashPathEffect(
                    intervals = intervals,
                    phase = phase
                )
            )
        )
    }
}

@Composable
fun BorderedBox(content: @Composable () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth().background(
                color = MaterialTheme.colorScheme.surface, // Change this to your desired background color
                shape = RoundedCornerShape(8.dp)
            )
            .border(1.dp, Color.Gray, RoundedCornerShape(8.dp))
            .padding(16.dp)
    ) {
        Column {
            content()
        }
    }
}

@Composable
fun ProfileField(label: String, value: String, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier.weight(1f)
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurface,
            textAlign = TextAlign.End,
        )
        Icon(
            imageVector = Icons.Default.ArrowForward,
            contentDescription = "Edit",
            tint = Color.Gray,
            modifier = Modifier.padding(start = 4.dp)
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditableField(label: String, value: String, onValueChange: (String) -> Unit) {
    Column {
        Spacer(modifier = Modifier.height(4.dp))
        TextField(
            label = { Text(label) },
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    color = MaterialTheme.colorScheme.surface, // Change this to your desired background color
                    shape = RoundedCornerShape(8.dp)
                )
                .border(1.dp, Color.Gray, RoundedCornerShape(8.dp)),
            value = value,
            onValueChange = onValueChange,
            textStyle = MaterialTheme.typography.bodyLarge,
            colors = TextFieldDefaults.textFieldColors(
                textColor = MaterialTheme.colorScheme.onBackground,
                containerColor = Color.Transparent,
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent,
                disabledIndicatorColor = Color.Transparent
            )
        )
    }
}