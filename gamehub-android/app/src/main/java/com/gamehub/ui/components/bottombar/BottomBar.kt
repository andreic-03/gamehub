package com.gamehub.ui.components.bottombar

import androidx.compose.foundation.background
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavController
import com.gamehub.ui.theme.LightGray

@Composable
fun BottomBar(
    navController: NavController,
    viewModel: BottomNavigationViewModel
) {
    val items = listOf(
        BottomNavItem.Home,
        BottomNavItem.Search,
        BottomNavItem.Add,
        BottomNavItem.Notifications,
        BottomNavItem.Profile
    )

    val selectedItem by viewModel.selectedItem.observeAsState(0)

    NavigationBar(
        containerColor = MaterialTheme.colorScheme.surface,
    ) {
        items.forEachIndexed { index, item ->
            NavigationBarItem(
                icon = {
                    Icon(
                        imageVector = item.icon,
                        contentDescription = null,
                    )
                },
                selected = selectedItem == index,
                onClick = {
                    viewModel.setSelectedItem(index)
                    navController.navigate(item.route)
                },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = MaterialTheme.colorScheme.onSurface,
                    unselectedIconColor = MaterialTheme.colorScheme.onSurface,
                    indicatorColor = MaterialTheme.colorScheme.background
                )
            )
        }
    }
}

sealed class BottomNavItem( val icon: ImageVector, val route: String) {
    data object Home : BottomNavItem(Icons.Default.Home, "home")
    data object Search : BottomNavItem(Icons.Default.Search, "search")
    data object Add : BottomNavItem(Icons.Default.Add, "add")
    data object Notifications : BottomNavItem(Icons.Default.Notifications, "notifications")
    data object Profile : BottomNavItem(Icons.Default.Person, "profile")
}