package com.gamehub.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.NavHostController
import com.gamehub.ui.components.base.BaseScreenLayout
import com.gamehub.ui.components.bottombar.BottomNavItem
import com.gamehub.ui.components.bottombar.BottomNavigationViewModel
import com.gamehub.ui.components.main.MainScreen
import com.gamehub.ui.components.login.LoginScreen
import com.gamehub.ui.components.profile.ProfileScreen
import com.gamehub.ui.components.profile.components.ChangePasswordScreen
import com.gamehub.ui.components.profile.components.EditAccountInfoScreen
import com.gamehub.ui.theme.DarkRed

@Composable
fun AppNavigation(navController: NavHostController) {
    val bottomNavigationViewModel: BottomNavigationViewModel = hiltViewModel();

    NavHost(
        navController,
        startDestination = "login"
    ) {
        composable("login") { LoginScreen(navController) }
        composable("main") { MainScreen(navController, bottomNavigationViewModel) }
        composable(BottomNavItem.Home.route) { MainScreen(navController, bottomNavigationViewModel) }
        composable(BottomNavItem.Search.route) { SearchScreen(navController, bottomNavigationViewModel) }
        composable(BottomNavItem.Add.route) { AddScreen(navController, bottomNavigationViewModel) }
        composable(BottomNavItem.Notifications.route) { NotificationsScreen(navController, bottomNavigationViewModel ) }
        composable(BottomNavItem.Profile.route) { ProfileScreen(navController, bottomNavigationViewModel) }
        composable("changePassword") { ChangePasswordScreen(navController) }
        composable("editField/{label}/{initialValue}") { backStackEntry ->
            val label = backStackEntry.arguments?.getString("label") ?: ""
            val initialValue = backStackEntry.arguments?.getString("initialValue") ?: ""
            EditAccountInfoScreen(navController, label, initialValue)
        }
    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchScreen(navController: NavController, navigationViewModel: BottomNavigationViewModel) {
    BaseScreenLayout(
        navController = navController,
        navigationViewModel = navigationViewModel,
        topBar = {
            TopAppBar(
                title = { Text("Search") },
                colors = TopAppBarDefaults.mediumTopAppBarColors(
                    containerColor = DarkRed,
                    titleContentColor = Color.White
                )
            )
        },
    ) { padding ->
        // Your screen content
        Text("Search Screen", modifier = Modifier.padding(padding))
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddScreen(navController: NavController, navigationViewModel: BottomNavigationViewModel) {
    BaseScreenLayout(
        navController = navController,
        navigationViewModel = navigationViewModel,
        topBar = {
            TopAppBar(
                title = { Text("Add") },
                colors = TopAppBarDefaults.mediumTopAppBarColors(
                    containerColor = DarkRed,
                    titleContentColor = Color.White
                )
            )
        },
    ) { padding ->
        // Your screen content
        Text("Add Screen", modifier = Modifier.padding(padding))
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotificationsScreen(navController: NavController, navigationViewModel: BottomNavigationViewModel) {
    BaseScreenLayout(
        navController = navController,
        navigationViewModel = navigationViewModel,
        topBar = {
            TopAppBar(
                title = { Text("Notif") },
                colors = TopAppBarDefaults.mediumTopAppBarColors(
                    containerColor = DarkRed,
                    titleContentColor = Color.White
                )
            )
        },
    ) { padding ->
        // Your screen content
        Text("Notifications Screen", modifier = Modifier.padding(padding))
    }
}
