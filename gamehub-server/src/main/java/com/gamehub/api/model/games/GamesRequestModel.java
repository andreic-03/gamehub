package com.gamehub.api.model.games;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GamesRequestModel {

    @NotBlank
    private String gameName;
    private String gameDescription;
    private String gameCategory;
}
