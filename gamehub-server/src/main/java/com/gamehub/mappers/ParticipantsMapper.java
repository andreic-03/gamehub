package com.gamehub.mappers;

import com.gamehub.api.model.participants.ParticipantsRequestModel;
import com.gamehub.api.model.participants.ParticipantsResponseModel;
import com.gamehub.persistance.entity.ParticipantsEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface ParticipantsMapper {

    @Mapping(source = "gamePost.postId", target = "gamePostId")
    @Mapping(source = "user.id", target = "userId")
    @Mapping(source = "isHost", target = "isHost")
    ParticipantsResponseModel toParticipantsModel(ParticipantsEntity participants);

    @Mapping(target = "participantId", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    ParticipantsEntity toParticipantsEntity(ParticipantsRequestModel participantsModel);

    @Mapping(target = "participantId", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    void updateParticipantsEntity(@MappingTarget ParticipantsEntity entity, ParticipantsRequestModel participantsModel);
}
