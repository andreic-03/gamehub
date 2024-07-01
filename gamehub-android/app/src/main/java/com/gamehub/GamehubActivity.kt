package com.gamehub

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.navigation.compose.rememberNavController
import com.gamehub.navigation.AppNavigation
import com.gamehub.ui.theme.GamehubTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class GamehubActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            GamehubTheme {
                Surface(
                    color = MaterialTheme.colorScheme.background,
                    content = {
                        val navController = rememberNavController()
                        AppNavigation(navController) }
                )
            }
        }
    }
}