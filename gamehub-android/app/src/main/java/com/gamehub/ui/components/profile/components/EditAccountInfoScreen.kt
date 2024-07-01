package com.gamehub.ui.components.profile.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.gamehub.ui.components.common.EditableField
import com.gamehub.ui.theme.LightGray

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditAccountInfoScreen(
    navController: NavController,
    label: String,
    initialValue: String,
    ) {

    var value by remember { mutableStateOf(initialValue) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Back"
                        )
                    }
                },
                actions = {
                    Spacer(Modifier.width(68.dp))
                },
                colors = TopAppBarDefaults.mediumTopAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary,
                )
            )
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(60.dp)
            ) {
                Text(
                    text = "Edit $label",
                    style = MaterialTheme.typography.titleLarge,
                    modifier = Modifier.align(Alignment.Center)
                )
            }
        }
    ) { innerPadding ->
        // Rest of your content remains the same
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp)
                .padding(horizontal = 40.dp)
                .verticalScroll(rememberScrollState())
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Spacer(modifier = Modifier.height(20.dp))
                EditableField(label = label, value = value, onValueChange = { value = it })
                Spacer(modifier = Modifier.height(16.dp))
                Button(
                    modifier = Modifier.fillMaxWidth(),
                    onClick = {
                        // Save the updated name and navigate back
                        navController.popBackStack()
                    }) {
                    Text(
                        text = "Save",
                        color = MaterialTheme.colorScheme.onTertiary
                    )
                }
            }
        }
    }
}