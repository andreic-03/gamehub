package com.gamehub.service.auth;

import com.gamehub.config.security.model.AppUserPrincipal;

import java.util.Optional;

public interface AppUserPrincipalService {
    Optional<AppUserPrincipal> getLoggedUserInfo();

    AppUserPrincipal getLoggedUserInfoOrThrow();
}
