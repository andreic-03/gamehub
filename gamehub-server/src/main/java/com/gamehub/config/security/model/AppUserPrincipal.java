package com.gamehub.config.security.model;

import com.gamehub.persistance.entity.UserEntity;
import com.gamehub.persistance.entity.UserStatus;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.stream.Collectors;

public record AppUserPrincipal(@Getter UserEntity userEntity) implements UserDetails {
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return userEntity.getRoles()
                .stream()
                .map(role -> new SimpleGrantedAuthority(role.getName()))
                .collect(Collectors.toList());
    }

    @Override
    public String getPassword() {
        return userEntity.getPassword();
    }

    @Override
    public String getUsername() {
        return userEntity.getUsername();
    }

    @Override
    public boolean isAccountNonExpired() {
        return userEntity.getStatus() != UserStatus.CREDENTIALS_EXPIRED;
    }

    @Override
    public boolean isAccountNonLocked() {
        return userEntity.getStatus() != UserStatus.LOCKED;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return UserStatus.CREDENTIALS_EXPIRED != userEntity.getStatus();
    }

    @Override
    public boolean isEnabled() {
        return UserStatus.ACTIVE == userEntity.getStatus();
    }
}
