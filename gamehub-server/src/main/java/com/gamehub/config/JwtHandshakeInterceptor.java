package com.gamehub.config;

import com.gamehub.service.auth.security.JwtTokenUtil;
import com.gamehub.service.security.TokenService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

/**
 * WebSocket handshake interceptor that allows connection establishment.
 *
 * Security Note: Authentication is now handled at the STOMP protocol level
 * via the Authorization header in STOMP CONNECT frames. This approach is more
 * secure as tokens are not exposed in URL query parameters (which get logged).
 *
 * The actual token validation happens in WebSocketConfig's ChannelInterceptor
 * when processing STOMP CONNECT commands.
 */
@Component
@Slf4j
@AllArgsConstructor
public class JwtHandshakeInterceptor implements HandshakeInterceptor {

    private final JwtTokenUtil jwtTokenUtil;
    private final TokenService tokenService;
    private final UserDetailsService userDetailsService;

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                   WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {
        // Allow WebSocket handshake - authentication will be validated at STOMP CONNECT level
        // This is more secure as token is not exposed in URL query parameters
        log.debug("WebSocket handshake initiated from: {}", request.getRemoteAddress());

        // Store services in session for later use during STOMP authentication
        attributes.put("jwtTokenUtil", jwtTokenUtil);
        attributes.put("tokenService", tokenService);
        attributes.put("userDetailsService", userDetailsService);

        return true;
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response,
                               WebSocketHandler wsHandler, Exception exception) {
        if (exception != null) {
            log.warn("WebSocket handshake failed: {}", exception.getMessage());
        }
    }
}
