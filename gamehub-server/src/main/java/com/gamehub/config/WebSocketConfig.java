package com.gamehub.config;

import com.gamehub.service.auth.security.JwtTokenUtil;
import com.gamehub.service.security.TokenService;
import lombok.AllArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import java.util.List;
import java.util.Map;

@Configuration
@EnableWebSocketMessageBroker
@AllArgsConstructor
@Order(Ordered.HIGHEST_PRECEDENCE + 99)
@Slf4j
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtHandshakeInterceptor jwtHandshakeInterceptor;
    private final UserDetailsService userDetailsService;
    private final JwtTokenUtil jwtTokenUtil;
    private final TokenService tokenService;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/chat.sendMessage")
                .addInterceptors(jwtHandshakeInterceptor)
                .setAllowedOriginPatterns("*");
        registry.addEndpoint("/chat.sendMessage")
                .addInterceptors(jwtHandshakeInterceptor)
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(new ChannelInterceptor() {
            @Override
            public Message<?> preSend(Message<?> message, MessageChannel channel) {
                StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

                if (accessor == null) {
                    return message;
                }

                StompCommand command = accessor.getCommand();

                // Handle STOMP CONNECT - authenticate via Authorization header
                if (command == StompCommand.CONNECT) {
                    return handleConnect(message, accessor);
                }

                // Handle SUBSCRIBE/SEND - restore authentication from session
                if (command == StompCommand.SUBSCRIBE || command == StompCommand.SEND) {
                    return handleAuthenticatedCommand(message, accessor);
                }

                return message;
            }

            private Message<?> handleConnect(Message<?> message, StompHeaderAccessor accessor) {
                String token = extractTokenFromHeaders(accessor);

                if (token == null) {
                    log.warn("STOMP CONNECT rejected: No Authorization header provided");
                    throw new SecurityException("Authentication required");
                }

                try {
                    // Validate token
                    if (!jwtTokenUtil.validateAccessToken(token)) {
                        log.warn("STOMP CONNECT rejected: Invalid token");
                        throw new SecurityException("Invalid token");
                    }

                    if (!tokenService.isUserSessionKnown(token)) {
                        log.warn("STOMP CONNECT rejected: Unknown session (token may be logged out)");
                        throw new SecurityException("Session expired");
                    }

                    // Extract username and load user details
                    String username = jwtTokenUtil.getSubject(token);
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                    // Create authentication
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

                    // Set in SecurityContext
                    SecurityContextHolder.getContext().setAuthentication(authentication);

                    // Store in session for subsequent messages
                    Map<String, Object> sessionAttributes = accessor.getSessionAttributes();
                    if (sessionAttributes != null) {
                        sessionAttributes.put("username", username);
                        sessionAttributes.put("SPRING.PRINCIPAL", authentication);
                    }

                    // Set the user on the accessor for Spring to use
                    accessor.setUser(authentication);

                    log.debug("STOMP CONNECT successful for user: {}", username);
                    return message;

                } catch (SecurityException e) {
                    throw e;
                } catch (Exception e) {
                    log.error("STOMP CONNECT failed: {}", e.getMessage(), e);
                    throw new SecurityException("Authentication failed: " + e.getMessage());
                }
            }

            private Message<?> handleAuthenticatedCommand(Message<?> message, StompHeaderAccessor accessor) {
                Map<String, Object> sessionAttributes = accessor.getSessionAttributes();

                if (sessionAttributes == null || !sessionAttributes.containsKey("username")) {
                    log.warn("STOMP {} rejected: No authenticated session", accessor.getCommand());
                    throw new SecurityException("Not authenticated");
                }

                String username = (String) sessionAttributes.get("username");

                try {
                    // Reload UserDetails for this thread
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

                    // Set in SecurityContext for this message handler thread
                    SecurityContextHolder.getContext().setAuthentication(authentication);

                    log.debug("STOMP {} authenticated for user: {}", accessor.getCommand(), username);
                    return message;

                } catch (Exception e) {
                    log.error("Failed to restore authentication: {}", e.getMessage(), e);
                    throw new SecurityException("Authentication restoration failed");
                }
            }

            private String extractTokenFromHeaders(StompHeaderAccessor accessor) {
                List<String> authHeaders = accessor.getNativeHeader(AUTHORIZATION_HEADER);

                if (authHeaders == null || authHeaders.isEmpty()) {
                    return null;
                }

                String authHeader = authHeaders.get(0);

                if (authHeader != null && authHeader.startsWith(BEARER_PREFIX)) {
                    return authHeader.substring(BEARER_PREFIX.length());
                }

                // Also accept raw token without Bearer prefix
                return authHeader;
            }
        });
    }
}
