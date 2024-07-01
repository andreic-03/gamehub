package com.gamehub.ui.components.login

import android.content.Context
import android.content.SharedPreferences
import android.widget.Toast
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.NavController
import com.gamehub.service.AuthService
import com.gamehub.model.auth.AuthRequestModel
import com.gamehub.model.auth.AuthResponseModel
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import javax.inject.Inject

@HiltViewModel
class LoginViewModel @Inject constructor(
    private val authService: AuthService,
    @ApplicationContext private val context: Context
) : ViewModel() {

    fun login(identifier: String, password: String, navController: NavController) {
        viewModelScope.launch {
            try {
                val request = AuthRequestModel(identifier, password)
                val response = withContext(Dispatchers.IO) {
                    authService.login(request).execute()
                }

                if (response.isSuccessful) {
                    val token = response.body()?.accessToken ?: return@launch
                    val sharedPreferences: SharedPreferences =
                        context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
                    with(sharedPreferences.edit()) {
                        putString("jwt_token", token)
                        apply()
                    }

                    // Navigate to the main screen
                    navController.navigate("main") {
                        popUpTo("login") { inclusive = true }
                    }
                } else {
                    Toast.makeText(context, "Login failed", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                Toast.makeText(context, "An error occurred: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }
}