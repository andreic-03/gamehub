package com.gamehub.api;

import com.gamehub.api.model.user.AdminUserUpdateRequestModel;
import com.gamehub.api.model.user.UserResponseModel;
import com.gamehub.api.model.user.UserStatusUpdateRequestModel;
import com.gamehub.service.user.UserService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import static com.gamehub.api.model.general.Constants.API_ADMIN_USERS;
import static com.gamehub.api.model.general.Constants.ROLE_ADMIN;

@RestController
@RequestMapping(API_ADMIN_USERS)
@AllArgsConstructor
@Validated
public class UserAdminController {

    private final UserService userService;

    @GetMapping("/{id}")
    @RolesAllowed(ROLE_ADMIN)
    public UserResponseModel getUserById(final @PathVariable Long id) {
        return userService.getById(id);
    }

    @PutMapping("/{id}")
    @RolesAllowed(ROLE_ADMIN)
    public UserResponseModel updateUser(@PathVariable Long id, @RequestBody @Valid AdminUserUpdateRequestModel adminUserModel) {
        return userService.updateUser(id, adminUserModel);
    }

    @PutMapping("/{id}/status")
    @RolesAllowed(ROLE_ADMIN)
    public UserResponseModel updateUserStatus(@PathVariable Long id, @RequestBody @Valid UserStatusUpdateRequestModel userModel) {
        return userService.updateUserStatus(id, userModel);
    }
}
