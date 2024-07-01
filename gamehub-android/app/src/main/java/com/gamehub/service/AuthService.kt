package com.gamehub.service

import com.gamehub.model.auth.AuthRequestModel
import com.gamehub.model.auth.AuthResponseModel
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST

interface AuthService {
    @POST("/api/auth/login")
    fun login(@Body request: AuthRequestModel): Call<AuthResponseModel>
}