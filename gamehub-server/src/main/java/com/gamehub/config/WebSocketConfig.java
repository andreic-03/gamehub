package com.gamehub.config;

import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubUnauthorizedException;
import com.gamehub.service.auth.security.JwtTokenUtil;
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
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
@AllArgsConstructor
//@Order(Ordered.HIGHEST_PRECEDENCE + 99)
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private JwtHandshakeInterceptor jwtHandshakeInterceptor;
    private JwtTokenUtil jwtTokenUtil;
    private UserDetailsService userDetailsService;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/chat.sendMessage").addInterceptors(jwtHandshakeInterceptor);
        registry.addEndpoint("/chat.sendMessage").addInterceptors(jwtHandshakeInterceptor).withSockJS();
    }

// TODO This will be used to verify the token
// TODO I'm not sure if it's working properly or the chat.sendMessage endpoint should be exposed as public
//
//    @Override
//    public void configureClientInboundChannel(ChannelRegistration registration) {
//        registration.interceptors(new ChannelInterceptor() {
//            @Override
//            public Message<?> preSend(Message<?> message, MessageChannel channel) {
//                StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
//                if (StompCommand.CONNECT.equals(accessor.getCommand())) {
//                    String authToken = accessor.getFirstNativeHeader("Authorization");
//                    if (authToken != null && authToken.startsWith("Bearer ")) {
//                        String token = authToken.substring(7);
//                        Authentication authentication = authenticateToken(token);
//                        accessor.setUser(authentication);
//                        SecurityContextHolder.getContext().setAuthentication(authentication);
//                    }
//                }
//                return message;
//            }
//        });
//    }
//
//    private Authentication authenticateToken(String token) {
//        UserDetails userDetails = userDetailsService.loadUserByUsername(jwtTokenUtil.getSubject(token));
//        if (jwtTokenUtil.validateAccessToken(token)) {
//            return new UsernamePasswordAuthenticationToken(userDetails, "", userDetails.getAuthorities());
//        } else {
//            throw new GamehubUnauthorizedException(ErrorType.AUTHENTICATION);
//        }
//    }
}
