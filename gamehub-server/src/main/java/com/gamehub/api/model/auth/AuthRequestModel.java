package com.gamehub.api.model.auth;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuthRequestModel {
    @NotBlank
    private String identifier;

    @NotBlank
    private String password;
}
