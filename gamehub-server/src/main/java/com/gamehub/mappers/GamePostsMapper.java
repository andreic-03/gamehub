package com.gamehub.mappers;

import com.gamehub.api.model.gameposts.GamePostsRequestModel;
import com.gamehub.api.model.gameposts.GamePostsResponseModel;
import com.gamehub.persistance.entity.GamePostsEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface GamePostsMapper {

    @Mapping(source = "hostUser.id", target = "hostUserId")
    @Mapping(source = "game.gameId", target = "gameId")
    GamePostsResponseModel toGamePostsModel(GamePostsEntity gamePosts);


    @Mapping(target = "postId", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    GamePostsEntity toGamePostsEntity(GamePostsRequestModel gamePosts);

    @Mapping(target = "postId", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    void updateGamePostEntity(@MappingTarget GamePostsEntity entity, GamePostsRequestModel gamePosts);
}
