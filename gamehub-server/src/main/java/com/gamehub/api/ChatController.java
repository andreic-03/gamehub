package com.gamehub.api;

import com.gamehub.api.model.messages.MessagesModel;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubNotFoundException;
import com.gamehub.config.exception.model.GamehubUnauthorizedException;
import com.gamehub.config.security.model.AppUserPrincipal;
import com.gamehub.service.auth.AppUserPrincipalService;
import com.gamehub.service.messages.MessagesService;
import lombok.AllArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;

import java.security.Principal;
import java.sql.Timestamp;


@Controller
@AllArgsConstructor
@Slf4j
public class ChatController {

    private final MessagesService messagesService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat.sendMessage")
    public void sendMessage(@AuthenticationPrincipal Principal user, @Payload MessagesModel chatMessage) {

        // Validate gamePostId is present
        if (chatMessage.getGamePostId() == null) {
            log.warn("Attempted to send message without gamePostId");
            throw new GamehubNotFoundException(ErrorType.GAME_POST_NOT_FOUND);
        }

        final String authenticatedUsername = user.getName();
        chatMessage.setSenderUsername(authenticatedUsername);

        // Save message with authenticated user
        messagesService.saveMessage(chatMessage);

        // Send message to the specific game post topic
        // Only users subscribed to this game post will receive the message
        String topic = "/topic/gamePost/" + chatMessage.getGamePostId();
        messagingTemplate.convertAndSend(topic, chatMessage);
        
        log.debug("Message sent to topic: {} from user: {}", topic, authenticatedUsername);
    }
}
