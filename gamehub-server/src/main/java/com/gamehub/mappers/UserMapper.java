package com.gamehub.mappers;

import com.gamehub.api.model.user.AdminUserUpdateRequestModel;
import com.gamehub.api.model.user.UserRegistrationRequestModel;
import com.gamehub.api.model.user.UserResponseModel;
import com.gamehub.api.model.user.UserUpdateRequestModel;
import com.gamehub.persistance.entity.RoleEntity;
import com.gamehub.persistance.entity.UserEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)

public interface UserMapper {

    UserResponseModel toUserModel(UserEntity user);

    @Mapping(target = "roles", ignore = true)
    @Mapping(target = "password", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "jwtTokens", ignore = true)
    UserEntity toUserEntity(UserRegistrationRequestModel user);

    @Mapping(target = "username", ignore = true)
    @Mapping(target = "roles", ignore = true)
    @Mapping(target = "password", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "jwtTokens", ignore = true)
    void updateUserEntity(@MappingTarget UserEntity entity, UserUpdateRequestModel updateEntity);

    @Mapping(target = "username", ignore = true)
    @Mapping(target = "roles", ignore = true)
    @Mapping(target = "password", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "jwtTokens", ignore = true)
    void updateUserEntity(@MappingTarget UserEntity entity, AdminUserUpdateRequestModel updateEntity);

    default String toRoleStr(RoleEntity role) {
        return role.getName();
    }
}
