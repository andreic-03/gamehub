package com.gamehub.service.user;

import com.gamehub.api.model.user.*;

public interface UserService {

    UserResponseModel getById(Long id);
    UserResponseModel getByUsername(String username);
    UserResponseModel registerUser(UserRegistrationRequestModel requestModel);
    UserResponseModel updateUser(Long id, UserUpdateRequestModel requestModel);
    UserResponseModel updateUser(Long id, AdminUserUpdateRequestModel requestModel);
    UserResponseModel updateUserStatus(Long id, UserStatusUpdateRequestModel requestModel);
    void changeUserPassword(Long id, ChangeUserPasswordRequestModel changeUserPasswordRequestModel);
}
