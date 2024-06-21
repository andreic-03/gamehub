package com.gamehub.service.gameposts;

import com.gamehub.api.model.gameposts.GamePostsRequestModel;
import com.gamehub.api.model.gameposts.GamePostsResponseModel;

public interface GamePostsService {

    GamePostsResponseModel createGamePost(Long hostId, GamePostsRequestModel gamePostsModel);
    GamePostsResponseModel updateGamePost(Long gamePostId, GamePostsRequestModel gamePostsModel);
    void delete(Long id);
}
