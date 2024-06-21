package com.gamehub.service.security;

import com.gamehub.persistance.entity.UserEntity;

public interface TokenService {
    void invalidateAllUserSession(UserEntity userEntity);
    boolean isUserSessionKnown(String jwtToken);
}
