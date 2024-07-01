package com.gamehub.ui.components.profile.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.gamehub.model.user.UserResponseModel
import com.gamehub.ui.components.common.BorderedBox
import com.gamehub.ui.components.common.DashedDivider
import com.gamehub.ui.components.common.ProfileField

@Composable
fun AccountInfoSection(userResponse: UserResponseModel, navController: NavController) {

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Text(
            text = "Account Info",
            style = MaterialTheme.typography.titleLarge,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier
                .padding(6.dp)
                .padding(top = 10.dp)
                .padding(bottom = 4.dp)
        )
        BorderedBox {
            ProfileField(
                label = "Full Name",
                value = userResponse.fullName,
                onClick = { navController.navigate("editField/Name/${userResponse.fullName}") }
            )
            DashedDivider(
                color = MaterialTheme.colorScheme.onSurface,
                thickness = 2.dp,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 15.dp)
            )
            ProfileField(
                label = "Email",
                value = userResponse.email,
                onClick = { navController.navigate("editField/Email/${userResponse.email}") }
            )
        }
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = "Password",
            style = MaterialTheme.typography.titleLarge,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier
                .padding(6.dp)
                .padding(bottom = 4.dp)
        )
        BorderedBox {
            ProfileField(
                label = "Change Password",
                value = "",
                onClick = { navController.navigate("changePassword") }
            )
        }
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = "Bio",
            style = MaterialTheme.typography.titleLarge,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier
                .padding(6.dp)
                .padding(bottom = 4.dp)
        )
        BorderedBox {
            Row(
                modifier = Modifier
                    .fillMaxWidth(),
                verticalAlignment = Alignment.Top
            ) {
                Text(
                    text = userResponse.bio,
                    modifier = Modifier.weight(1f),
                    style = MaterialTheme.typography.bodyLarge.copy(
                        lineHeight = 20.sp,
                        color = MaterialTheme.colorScheme.onSurface
                    ),
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis
                )
                IconButton(
                    onClick = { navController.navigate("editField/Bio/${userResponse.bio}") },
                    modifier = Modifier
                        .align(Alignment.CenterVertically)
                ) {
                    Icon(
                        imageVector = Icons.Default.Edit,
                        contentDescription = "Edit Bio",
                        tint = MaterialTheme.colorScheme.onSurface
                    )
                }
            }
        }
    }
}