package com.gamehub.ui.fragments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import com.gamehub.model.user.UserResponseModel

//class AccountInfoFragment : Fragment() {
//    override fun onCreateView(
//        inflater: LayoutInflater, container: ViewGroup?,
//        savedInstanceState: Bundle?
//    ): View? {
//        // Create a ComposeView and set its content
//        return ComposeView(requireContext()).apply {
//            setContent {
//                val userResponse = arguments?.getParcelable<UserResponseModel>("userResponse")
//                AccountInfoComposable(userResponse)
//            }
//        }
//    }
//}
//
//@Composable
//fun AccountInfoComposable(userResponse: UserResponseModel?) {
//    Column(
//        modifier = Modifier
//            .fillMaxWidth()
//            .padding(16.dp)
//    ) {
//        Text(
//            text = "Account Information",
//            style = MaterialTheme.typography.titleSmall,
//            color = Color.Black
//        )
//        Spacer(modifier = Modifier.height(8.dp))
//        Text(
//            text = "Email: ${userResponse?.email ?: "N/A"}",
//            style = MaterialTheme.typography.bodySmall,
//            color = Color.Black
//        )
//    }
//}