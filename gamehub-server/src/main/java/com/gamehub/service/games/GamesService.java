package com.gamehub.service.games;

import com.gamehub.api.model.games.GamesRequestModel;
import com.gamehub.api.model.games.GamesResponseModel;

import java.util.List;

public interface GamesService {

    List<GamesResponseModel> getAll();
    GamesResponseModel createGame(GamesRequestModel gamesModel);
    GamesResponseModel updateGame(Long gameId, GamesRequestModel gamesModel);
    void delete(Long id);
    List<GamesResponseModel> getGameByName(String gameName);
}
