package com.gamehub.api.model.messages;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class MessagesModel {
    private Long gamePostId;
    private String senderUsername;
    private String messageContent;
    private Timestamp sentAt;
}
