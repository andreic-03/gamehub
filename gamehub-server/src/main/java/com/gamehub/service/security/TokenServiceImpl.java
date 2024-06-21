package com.gamehub.service.security;

import com.gamehub.persistance.entity.UserEntity;
import com.gamehub.persistance.repository.TokenRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@AllArgsConstructor
public class TokenServiceImpl implements TokenService {

    private final TokenRepository tokenRepository;

    @Override
    @Transactional
    public void invalidateAllUserSession(final UserEntity userEntity) {
        tokenRepository.deleteAllByUser(userEntity);
    }

    @Override
    public boolean isUserSessionKnown(final String jwtToken) {
        return tokenRepository.existsByToken(jwtToken);
    }

}
