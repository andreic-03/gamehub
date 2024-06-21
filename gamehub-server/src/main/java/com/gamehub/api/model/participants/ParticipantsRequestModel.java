package com.gamehub.api.model.participants;

import com.gamehub.persistance.entity.ParticipantsEntity;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ParticipantsRequestModel {
    @NotNull
    private Long gamePostId;

    @NotNull
    private ParticipantsEntity.Status status;
}
