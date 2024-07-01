package com.gamehub.model.user

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

//@Parcelize
data class UserResponseModel(
    val id: Long,
    val username: String,
    val email: String,
    val status: String,
    val fullName: String,
    val bio: String,
    val profilePictureUrl: String,
    val lastLogin: String,
    val roles: Set<String>
)
