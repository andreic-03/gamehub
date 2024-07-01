package com.gamehub.interceptor

import android.content.Context
import android.content.SharedPreferences
import dagger.hilt.android.qualifiers.ApplicationContext
import okhttp3.Interceptor
import okhttp3.Request
import okhttp3.Response
import javax.inject.Inject

class AuthInterceptor @Inject constructor(
    @ApplicationContext private val context: Context
) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()

        if (originalRequest.url.encodedPath == "/api/auth/login") {
            return chain.proceed(originalRequest)
        }

        val sharedPreferences: SharedPreferences = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
        val token: String = sharedPreferences.getString("jwt_token", null)
            ?: return chain.proceed(originalRequest)

        val builder: Request.Builder = originalRequest.newBuilder()
            .header("Authorization", "Bearer $token")

        val newRequest: Request = builder.build()
        return chain.proceed(newRequest)
    }
}