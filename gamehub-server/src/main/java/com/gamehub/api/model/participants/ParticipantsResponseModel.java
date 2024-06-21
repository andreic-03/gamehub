package com.gamehub.api.model.participants;

import com.gamehub.persistance.entity.ParticipantsEntity;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class ParticipantsResponseModel {
    private Long participantId;
    private Long gamePostId;
    private Long userId;
    private ParticipantsEntity.Status status;
    private LocalDateTime joinedAt;
}
