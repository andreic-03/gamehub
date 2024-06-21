package com.gamehub.api;

import com.gamehub.api.model.auth.AuthRequestModel;
import com.gamehub.service.auth.AuthService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.Optional;

import static com.gamehub.api.model.general.Constants.*;

@RestController
@RequestMapping(API_AUTH)
@AllArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody @Valid AuthRequestModel request) {
        return ResponseEntity
                .ok()
                .body(authService.doLogin(request));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        authService.doLogout(getJwtFromRequest());

        return ResponseEntity
                .noContent()
                .build();
    }

    private String getJwtFromRequest() {
        return Optional.ofNullable(RequestContextHolder.getRequestAttributes())
                .filter(ServletRequestAttributes.class::isInstance)
                .map(ServletRequestAttributes.class::cast)
                .map(ServletRequestAttributes::getRequest)
                .map(request -> request.getHeader(AUTHORIZATION_HEADER_NAME))
                .map(authHeader -> authHeader.replace(String.format("%s ", ACCESS_TOKEN_PREFIX_NAME), ""))
                .orElse("");
    }
}