package com.gamehub.api.model.user;

import com.gamehub.persistance.entity.UserStatus;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Set;

@Getter
@Setter
public class UserResponseModel {
    private Long id;
    private String username;
    private String email;
    private UserStatus status;
    private String fullName;
    private String bio;
    private String profilePictureUrl;
    private LocalDateTime lastLogin;
    private Set<String> roles;
}
