package com.gamehub.service.participants;

import com.gamehub.api.model.participants.ParticipantsRequestModel;
import com.gamehub.api.model.participants.ParticipantsResponseModel;

import java.util.List;

public interface ParticipantsService {
    List<ParticipantsResponseModel> getAll();
    ParticipantsResponseModel createParticipant(Long userId, ParticipantsRequestModel participantModel);
    ParticipantsResponseModel updateParticipant(Long participantId, ParticipantsRequestModel participantModel);
    void delete(Long id);
    boolean isUserJoined(Long userId, Long gamePostId);
    void leaveGame(Long userId, Long gamePostId);
}
