package com.gamehub.api;

import com.gamehub.api.model.user.UserResponseModel;
import com.gamehub.config.security.model.AppUserPrincipal;
import com.gamehub.service.user.UserService;
import lombok.AllArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static com.gamehub.api.model.general.Constants.API_USERS;

@RestController
@RequestMapping(API_USERS)
@AllArgsConstructor
public class UserController {
    private final UserService userService;

    @GetMapping("info")
    public UserResponseModel getCurrentUser(@AuthenticationPrincipal AppUserPrincipal user) {
        return userService.getByUsername(user.getUsername());
    }
}
