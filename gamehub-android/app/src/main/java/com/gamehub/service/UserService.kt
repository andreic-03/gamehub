package com.gamehub.service

import com.gamehub.model.user.UserResponseModel
import retrofit2.Call
import retrofit2.http.GET

interface UserService {
    @GET("/api/user/info")
    fun getCurrentUser(): Call<UserResponseModel>
}