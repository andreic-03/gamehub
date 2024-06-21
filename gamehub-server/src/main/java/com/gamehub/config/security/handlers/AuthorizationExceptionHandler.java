package com.gamehub.config.security.handlers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.service.internationalization.TranslateService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@AllArgsConstructor
public class AuthorizationExceptionHandler implements AccessDeniedHandler {
    private final TranslateService translateService;
    private final ObjectMapper mapper;

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException, ServletException {
        response.setStatus(HttpStatus.FORBIDDEN.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        var errorMessage = translateService.translate(ErrorType.AUTHORIZATION);
        var body = mapper.writeValueAsBytes(errorMessage);
        response.getOutputStream().write(body);
    }
}
