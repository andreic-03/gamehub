package com.gamehub.api.model.user;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChangeUserPasswordRequestModel {
    @NotBlank
    private String oldPassword;

    @NotBlank
    private String newPassword;
}