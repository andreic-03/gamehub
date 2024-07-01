package com.gamehub.api;

import com.gamehub.api.model.messages.MessagesModel;
import com.gamehub.service.messages.MessagesService;
import lombok.AllArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.stereotype.Controller;

import java.sql.Timestamp;


@Controller
@AllArgsConstructor
public class ChatController {

    private final MessagesService messagesService;

    @MessageMapping("/chat.sendMessage")
    @SendTo("/topic")
    public MessagesModel sendMessage(@Payload MessagesModel chatMessage) {
        messagesService.saveMessage(chatMessage);
        chatMessage.setSentAt(new Timestamp(System.currentTimeMillis()));
        return chatMessage;
    }

    @MessageMapping("/chat.addUser")
    @SendTo("/topic")
    public String addUser(@Payload String username, SimpMessageHeaderAccessor headerAccessor) {
        headerAccessor.getSessionAttributes().put("username", username);
        return username;
    }

}
