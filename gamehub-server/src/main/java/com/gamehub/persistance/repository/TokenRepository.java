package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.TokenEntity;
import com.gamehub.persistance.entity.UserEntity;
import org.springframework.data.repository.CrudRepository;

import java.time.LocalDateTime;

public interface TokenRepository extends CrudRepository<TokenEntity, Long> {
    boolean existsByToken(final String token);
    void deleteByToken(final String token);
    void deleteAllByUser(final UserEntity userEntity);

    void deleteByCreatedOnBefore(final LocalDateTime localDateTime);
}
