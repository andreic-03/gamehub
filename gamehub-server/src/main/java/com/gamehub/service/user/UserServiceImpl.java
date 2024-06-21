package com.gamehub.service.user;

import com.gamehub.api.model.user.*;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubBadRequestException;
import com.gamehub.config.exception.model.GamehubNotFoundException;
import com.gamehub.mappers.UserMapper;
import com.gamehub.persistance.entity.RoleEntity;
import com.gamehub.persistance.entity.UserEntity;
import com.gamehub.persistance.entity.UserStatus;
import com.gamehub.persistance.repository.RoleRepository;
import com.gamehub.persistance.repository.UserRepository;
import com.gamehub.service.date.DateTimeServiceWrapper;
import com.gamehub.service.security.TokenService;
import lombok.AllArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

import static com.gamehub.api.model.general.Constants.ROLE_USER;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final DateTimeServiceWrapper dateTimeServiceWrapper;
    private final TokenService tokenService;

    @Transactional
    @Override
    public UserResponseModel getById(Long id) {
        return userRepository.findById(id)
                .map(userMapper::toUserModel)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.USER_NOT_FOUND));
    }

    @Transactional
    @Override
    public UserResponseModel getByUsername(String username) {
        return userRepository.findByUsername(username)
                .map(userMapper::toUserModel)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.USER_NOT_FOUND));
    }

    @Transactional
    @Override
    public UserResponseModel registerUser(UserRegistrationRequestModel requestModel) {
        UserEntity userEntity = userMapper.toUserEntity(requestModel);

        Set<String> userRole = new HashSet<>();
        userRole.add(ROLE_USER);

        Set<RoleEntity> roles = mapRoles(userRole);

        userEntity.setRoles(roles);
//        userEntity.setStatus(UserStatus.WAITING_CONFIRMATION); TODO Implement sending registration email to confirm email
        userEntity.setStatus(UserStatus.ACTIVE);
        userEntity.setPassword(passwordEncoder.encode(requestModel.getPassword()));
        userEntity.setLastLogin(dateTimeServiceWrapper.now());

        userRepository.save(userEntity);

        return userMapper.toUserModel(userEntity);
    }

    @Transactional
    @Override
    public UserResponseModel updateUser(Long id, UserUpdateRequestModel updateRequestModel) {
        UserEntity existingUser = getUserById(id);

        userMapper.updateUserEntity(existingUser, updateRequestModel);

        UserEntity savedUser = userRepository.save(existingUser);
        return userMapper.toUserModel(savedUser);
    }

    @Transactional
    @Override
    public UserResponseModel updateUser(Long id, AdminUserUpdateRequestModel requestModel) {
        UserEntity existingUser = getUserById(id);

        userMapper.updateUserEntity(existingUser, requestModel);

        Set<RoleEntity> roles = mapRoles(requestModel.getRoles());
        existingUser.setRoles(roles);

        UserEntity savedUser = userRepository.save(existingUser);
        return userMapper.toUserModel(savedUser);
    }

    @Transactional
    @Override
    public UserResponseModel updateUserStatus(Long id, UserStatusUpdateRequestModel requestModel) {
        UserEntity existingUser = getUserById(id);

        existingUser.setStatus(requestModel.getStatus());

        if (requestModel.getStatus() == UserStatus.LOCKED) {
            this.tokenService.invalidateAllUserSession(existingUser);
        }

        return userMapper.toUserModel(existingUser);
    }

    @Transactional
    @Override
    public void changeUserPassword(Long id, ChangeUserPasswordRequestModel changeUserPasswordRequestModel) {
        UserEntity existingUser = getUserById(id);

        final var oldPassword = changeUserPasswordRequestModel.getOldPassword();
        if (!passwordEncoder.matches(oldPassword, existingUser.getPassword())) {
            throw new GamehubBadRequestException(ErrorType.OLD_PASSWORD_DID_NOT_MATCH);
        }

        final var newHashedPassword = passwordEncoder.encode(changeUserPasswordRequestModel.getNewPassword());
        existingUser.setPassword(newHashedPassword);

        tokenService.invalidateAllUserSession(existingUser);
    }

    private UserEntity getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.USER_NOT_FOUND));
    }

    private Set<RoleEntity> mapRoles(Set<String> roles) {
        return roles
                .stream()
                .map(roleRepository::findByName)
                .map(roleEntity -> roleEntity.orElseThrow(() -> new GamehubNotFoundException(ErrorType.ROLE_NOT_FOUND)))
                .collect(Collectors.toSet());
    }
}
