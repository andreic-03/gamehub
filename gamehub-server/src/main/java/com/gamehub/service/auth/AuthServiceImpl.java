package com.gamehub.service.auth;

import com.gamehub.api.model.auth.AuthRequestModel;
import com.gamehub.api.model.auth.AuthResponseModel;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubUnauthorizedException;
import com.gamehub.config.security.model.AppUserPrincipal;
import com.gamehub.mappers.AuthMapper;
import com.gamehub.mappers.TokenMapper;
import com.gamehub.persistance.entity.UserEntity;
import com.gamehub.persistance.repository.TokenRepository;
import com.gamehub.persistance.repository.UserRepository;
import com.gamehub.service.auth.security.JwtTokenUtil;
import com.gamehub.service.date.DateTimeServiceWrapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
@AllArgsConstructor
public class AuthServiceImpl implements AuthService {
    private final AuthenticationManager authManager;
    private final JwtTokenUtil jwtUtil;
    private final TokenMapper tokenMapper;
    private final AuthMapper authMapper;
    private final TokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final DateTimeServiceWrapper dateTimeServiceWrapper;

    @Transactional
    @Override
    public AuthResponseModel doLogin(AuthRequestModel authRequestModel) {
        final Authentication authentication;

        try {
            String username = determineUsername(authRequestModel.getIdentifier());

            authentication =
                    authManager.authenticate(
                            new UsernamePasswordAuthenticationToken(username, authRequestModel.getPassword())
                    );
        } catch (BadCredentialsException | LockedException ex) {
            log.error(ex.getMessage());
            throw new GamehubUnauthorizedException(ErrorType.AUTHENTICATION);
        }

        final var user = (AppUserPrincipal) authentication.getPrincipal();
        final var accessToken = jwtUtil.generateAccessToken(user);
        var userEntity = user.getUserEntity();
        tokenRepository.save(tokenMapper.toTokenEntity(accessToken, userEntity));

        userEntity.setLastLogin(dateTimeServiceWrapper.now());
        userRepository.save(userEntity);

        return authMapper.toAuthResponseModel(user.getUsername(), accessToken);
    }

    @Transactional
    @Override
    public void doLogout(String jwtToken) {
        tokenRepository.deleteByToken(jwtToken);
    }

    private String determineUsername(String identifier) {
        if (identifier.contains("@")) {
            return userRepository.findByEmail(identifier)
                    .map(UserEntity::getUsername)
                    .orElseThrow(() -> new GamehubUnauthorizedException(ErrorType.AUTHENTICATION));
        }

        return identifier;
    }
}
