package com.gamehub.api;

import com.gamehub.api.model.messages.MessagesModel;
import com.gamehub.service.messages.MessagesService;
import jakarta.annotation.security.RolesAllowed;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.gamehub.api.model.general.Constants.*;

@RestController
@RequestMapping(API_MESSAGES)
@AllArgsConstructor
public class MessagesController {

    private final MessagesService messagesService;

    @GetMapping("/game-post/{gamePostId}")
    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    public List<MessagesModel> getMessagesByGamePostId(@PathVariable("gamePostId") final Long gamePostId) {
        return messagesService.getMessagesByGamePostId(gamePostId);
    }
}


