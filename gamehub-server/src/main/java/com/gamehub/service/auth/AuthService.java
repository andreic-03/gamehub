package com.gamehub.service.auth;

import com.gamehub.api.model.auth.AuthRequestModel;
import com.gamehub.api.model.auth.AuthResponseModel;

public interface AuthService {
    AuthResponseModel doLogin(final AuthRequestModel authRequestModel);
    void doLogout(final String jwtToken);
}
