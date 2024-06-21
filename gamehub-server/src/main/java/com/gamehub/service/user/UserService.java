package com.gamehub.service.user;

import com.gamehub.api.model.user.UserResponseModel;

public interface UserService {

    UserResponseModel getByUsername(String username);
}
