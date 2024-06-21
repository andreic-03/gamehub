package com.gamehub.api.model.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.util.Set;

@Getter
@Setter
public class AdminUserUpdateRequestModel {
    @NotNull
    @Email
    private String email;

    @NotNull
    @Size(min = 5, max = 60)
    private String fullName;

    private String bio;
    private String profilePictureUrl;
    @NotEmpty
    private Set<String> roles;
}
