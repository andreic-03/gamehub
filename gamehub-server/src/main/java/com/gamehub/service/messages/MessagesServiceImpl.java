package com.gamehub.service.messages;

import com.gamehub.api.model.messages.MessagesModel;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubNotFoundException;
import com.gamehub.persistance.entity.MessagesEntity;
import com.gamehub.persistance.repository.GamePostsRepository;
import com.gamehub.persistance.repository.MessagesRepository;
import com.gamehub.persistance.repository.UserRepository;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;

@Slf4j
@Service
@AllArgsConstructor
public class MessagesServiceImpl implements MessagesService {

    private final GamePostsRepository gamePostsRepository;
    private final UserRepository userRepository;
    private final MessagesRepository messagesRepository;

    @Transactional
    @Override
    public void saveMessage(MessagesModel messagesModel) {
        MessagesEntity messages = new MessagesEntity();
        var gamePost = gamePostsRepository.findById(messagesModel.getGamePostId())
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.GAME_POST_NOT_FOUND));
        var senderUser = userRepository.findByUsername(messagesModel.getSenderUsername())
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.USER_NOT_FOUND));

        messages.setGamePost(gamePost);
        messages.setSenderUser(senderUser);
        messages.setMessageContent(messagesModel.getMessageContent());
        messages.setSentAt(new Timestamp(System.currentTimeMillis()));

        messagesRepository.save(messages);
    }
}
