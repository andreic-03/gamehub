package com.gamehub.service.messages;

import com.gamehub.api.model.messages.MessagesModel;

import java.util.List;

public interface MessagesService {

    void saveMessage(MessagesModel messagesModel);
    
    List<MessagesModel> getMessagesByGamePostId(Long gamePostId);
}
