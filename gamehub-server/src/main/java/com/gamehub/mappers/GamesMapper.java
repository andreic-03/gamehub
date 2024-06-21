package com.gamehub.mappers;

import com.gamehub.api.model.games.GamesRequestModel;
import com.gamehub.api.model.games.GamesResponseModel;
import com.gamehub.persistance.entity.GamesEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface GamesMapper {

    GamesResponseModel toGamesModel(GamesEntity games);

    @Mapping(target = "gameId", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    GamesEntity toGamesEntity(GamesRequestModel gamesRequest);

    @Mapping(target = "gameId", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    void updateGamesEntity(@MappingTarget GamesEntity entity, GamesRequestModel gamesRequest);
}
