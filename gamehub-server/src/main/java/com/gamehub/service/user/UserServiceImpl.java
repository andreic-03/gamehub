package com.gamehub.service.user;

import com.gamehub.api.model.user.UserResponseModel;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubNotFoundException;
import com.gamehub.mappers.UserMapper;
import com.gamehub.persistance.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService{

    UserRepository userRepository;
    UserMapper userMapper;

    @Override
    public UserResponseModel getByUsername(String username) {
        return userRepository.findByUsername(username)
                .map(userMapper::toUserModel)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.USER_NOT_FOUND));
    }
}
