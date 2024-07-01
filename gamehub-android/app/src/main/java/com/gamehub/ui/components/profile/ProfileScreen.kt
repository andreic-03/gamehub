package com.gamehub.ui.components.profile

//import com.gamehub.ui.fragments.AccountInfoFragment
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.gamehub.R
import com.gamehub.model.user.UserResponseModel
import com.gamehub.ui.components.base.BaseScreenLayout
import com.gamehub.ui.components.bottombar.BottomNavigationViewModel
import com.gamehub.ui.components.main.MainViewModel
import com.gamehub.ui.components.profile.components.AccountInfoSection
import com.gamehub.ui.theme.LightGray


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(navController: NavController, navigationViewModel: BottomNavigationViewModel) {
    val mainViewModel: MainViewModel = hiltViewModel()
    val userResponse by mainViewModel.userResponse.observeAsState()
    val scrollState = rememberScrollState()

    val userResponseModel = UserResponseModel(
        id = 1L,
        username = "john_doe",
        email = "john.doe@example.com",
        status = "Active",
        fullName = "John Doe",
        bio = "Software developer and tech enthusiast",
        profilePictureUrl = "https://example.com/profile.jpg",
        lastLogin = "2024-06-28T10:30:00Z",
        roles = setOf("USER", "ADMIN")
    )

    BaseScreenLayout(
        navController = navController,
        navigationViewModel = navigationViewModel,
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        modifier = Modifier.fillMaxSize(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Image(
                            painter = painterResource(R.drawable.ic_launcher_foreground),
                            contentDescription = "User Avatar",
                            modifier = Modifier.size(60.dp)
                        )
                        Spacer(modifier = Modifier.weight(1f))
                        Column(
                            verticalArrangement = Arrangement.Center,
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text(
                                text = userResponseModel.fullName,
                                style = MaterialTheme.typography.titleMedium,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                            Text(
                                text = userResponseModel.status,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                        }
                        Spacer(modifier = Modifier.weight(1f))
                        IconButton(
                            onClick = { /* Handle settings click */ },
                            modifier = Modifier.padding(end = 16.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Settings,
                                contentDescription = "Settings",
                                tint = MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.mediumTopAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                    titleContentColor = MaterialTheme.colorScheme.onSurface
                )
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .verticalScroll(scrollState)
        ) {
            Column(
                modifier = Modifier
                    .padding(14.dp)
            ) {
                userResponse?.let { AccountInfoSection(it, navController) }

//                AccountInfoSection(userResponseModel, navController) // Use the composable directly
            }

            Button(
                onClick = { /* Handle login click */ },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                Text(
                    text = "Logout",
                    color = MaterialTheme.colorScheme.onTertiary
                )
            }
        }
    }
}


// Fragment stuff
//Column(modifier = Modifier.padding(padding)) {
//    AndroidView(factory = { context ->
//        FragmentContainerView(context).apply {
//            id = View.generateViewId()
//        }.also { fragmentContainerView ->
//            val fragment = AccountInfoFragment().apply {
//                arguments = Bundle().apply {
//                    putParcelable("userResponse", userResponse)
//                }
//            }
//            (context as FragmentActivity).supportFragmentManager.commit {
//                replace(fragmentContainerView.id, fragment)
//            }
//        }
//    }, modifier = Modifier.fillMaxSize())
//}