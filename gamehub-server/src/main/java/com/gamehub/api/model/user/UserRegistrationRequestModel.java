package com.gamehub.api.model.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserRegistrationRequestModel {
    @NotNull
    @Size(min = 5, max = 50)
    private String username;

    @NotNull
    @Size(min = 8, max = 50)
    private String password;

    @NotNull
    @Email
    private String email;

    @NotNull
    @Size(min = 5, max = 60)
    private String fullName;
}
