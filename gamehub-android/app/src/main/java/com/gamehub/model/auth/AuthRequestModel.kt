package com.gamehub.model.auth

data class AuthRequestModel(
    val identifier: String,
    val password: String
)