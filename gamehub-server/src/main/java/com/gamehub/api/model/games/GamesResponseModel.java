package com.gamehub.api.model.games;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GamesResponseModel {
    private Long gameId;
    private String gameName;
    private String gameDescription;
    private String gameCategory;
}
