package com.gamehub.api.model.user;

import com.gamehub.persistance.entity.UserStatus;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserStatusUpdateRequestModel {
    private UserStatus status;
}
