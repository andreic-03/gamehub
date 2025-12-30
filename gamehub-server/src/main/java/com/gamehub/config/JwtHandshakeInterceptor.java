package com.gamehub.config;

import com.gamehub.config.security.model.AppUserPrincipal;
import com.gamehub.service.auth.security.JwtTokenUtil;
import com.gamehub.service.security.TokenService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

@Component
@Slf4j
@AllArgsConstructor
public class JwtHandshakeInterceptor implements HandshakeInterceptor {

    private final JwtTokenUtil jwtTokenUtil;
    private final TokenService tokenService;
    private final UserDetailsService userDetailsService;

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {
        String token = extractToken(request);
        if (token != null) {
            try {
                // Validate token (same as HTTP filter)
                if (!jwtTokenUtil.validateAccessToken(token) || !tokenService.isUserSessionKnown(token)) {
                    log.warn("Invalid token or unknown session during WebSocket handshake");
                    return false;
                }

                // Extract username from token
                String username = jwtTokenUtil.getSubject(token);
                
                // CRITICAL: Load full AppUserPrincipal with UserEntity (same as JwtTokenFilter)
                // This is why @AuthenticationPrincipal AppUserPrincipal works in HTTP but not WebSocket
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                
                // Create authentication with AppUserPrincipal as principal
                UsernamePasswordAuthenticationToken authentication = 
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                
                SecurityContextHolder.getContext().setAuthentication(authentication);

                // Store username in session attributes for later use
                attributes.put("username", username);
                attributes.put("SPRING.PRINCIPAL", authentication);

                return true;
            } catch (Exception e) {
                log.error("Error during handshake: {}", e.getMessage(), e);
            }
        }

        return false; // Reject the handshake if the token is invalid
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler, Exception exception) {
        // No implementation needed for after handshake
    }

    private String extractToken(ServerHttpRequest request) {
        String query = request.getURI().getQuery();
        String token = null;
        if (query != null) {
            for (String param : query.split("&")) {
                String[] pair = param.split("=");
                if ("token".equals(pair[0]) && pair.length > 1) {
                    token = pair[1];
                    break;
                }
            }
        }

        return token;
    }
}
