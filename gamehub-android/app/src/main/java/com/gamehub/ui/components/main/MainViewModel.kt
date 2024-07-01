package com.gamehub.ui.components.main

import android.content.Context
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.gamehub.api.ApiClient
import com.gamehub.service.UserService
import com.gamehub.model.user.UserResponseModel
import com.gamehub.service.AuthService
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
class MainViewModel @Inject constructor(
    private val userService: UserService,
    @ApplicationContext private val context: Context
): ViewModel() {

    private val _userResponse = MutableLiveData<UserResponseModel>()
    val userResponse: LiveData<UserResponseModel> = _userResponse

    init {
        getCurrentUser()
    }

    private fun getCurrentUser() {
        viewModelScope.launch {
            withContext(Dispatchers.IO) {
                userService.getCurrentUser().enqueue(object : Callback<UserResponseModel> {
                    override fun onResponse(
                        call: Call<UserResponseModel>,
                        response: Response<UserResponseModel>
                    ) {
                        if (response.isSuccessful) {
                            _userResponse.postValue(response.body())
                        }
                    }

                    override fun onFailure(call: Call<UserResponseModel>, t: Throwable) {
                        Log.e("MainViewModel", "Network call failed: ${t.message}")
                    }
                })
            }
        }
    }
}