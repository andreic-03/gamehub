package com.gamehub.ui.components.main

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.gamehub.ui.components.base.BaseScreenLayout
import com.gamehub.ui.components.bottombar.BottomNavigationViewModel
import com.gamehub.ui.theme.DarkRed

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    navController: NavController,
    bottomNavigationViewModel: BottomNavigationViewModel
) {
    val mainViewModel: MainViewModel = hiltViewModel()
    val userResponse by mainViewModel.userResponse.observeAsState()

    BaseScreenLayout(
        navController = navController,
        navigationViewModel = bottomNavigationViewModel,
        topBar = {
            TopAppBar(
                title = { Text("Home") },
                colors = TopAppBarDefaults.mediumTopAppBarColors(
                    containerColor = DarkRed,
                    titleContentColor = Color.White
                )
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
        ) {

            Text(
                text = "Welcome, ${userResponse?.fullName}"
            )
        }
    }
}