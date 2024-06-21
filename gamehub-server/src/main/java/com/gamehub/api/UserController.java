package com.gamehub.api;

import com.gamehub.api.model.user.ChangeUserPasswordRequestModel;
import com.gamehub.api.model.user.UserRegistrationRequestModel;
import com.gamehub.api.model.user.UserResponseModel;
import com.gamehub.api.model.user.UserUpdateRequestModel;
import com.gamehub.config.security.model.AppUserPrincipal;
import com.gamehub.service.user.UserService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping("/registration")
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponseModel registerUser(@RequestBody @Valid final UserRegistrationRequestModel userModel) {
        return userService.registerUser(userModel);
    }

    @PutMapping
    public UserResponseModel updateUser(@AuthenticationPrincipal AppUserPrincipal user,
                                        @RequestBody @Valid final UserUpdateRequestModel userModel) {
        return userService.updateUser(user.getUserEntity().getId(), userModel);
    }

    @PutMapping("/password-reset")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void changeUserPassword(@AuthenticationPrincipal AppUserPrincipal user,
                                   @RequestBody @Valid final ChangeUserPasswordRequestModel changeUserPasswordRequestModel) {
        userService.changeUserPassword(user.getUserEntity().getId(), changeUserPasswordRequestModel);
    }
}
