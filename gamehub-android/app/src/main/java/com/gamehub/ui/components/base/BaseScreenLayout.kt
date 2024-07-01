package com.gamehub.ui.components.base

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.navigation.NavController
import com.gamehub.ui.components.bottombar.BottomBar
import com.gamehub.ui.components.bottombar.BottomNavigationViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BaseScreenLayout(
    navController: NavController,
    navigationViewModel: BottomNavigationViewModel,
    topBar: @Composable () -> Unit,
    content: @Composable (PaddingValues) -> Unit
) {
    Scaffold(
        topBar = topBar,
        bottomBar = { BottomBar(navController, navigationViewModel) },
        content = content
    )
}