package com.gamehub.service.participants;

import com.gamehub.api.model.participants.ParticipantsRequestModel;
import com.gamehub.api.model.participants.ParticipantsResponseModel;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubBadRequestException;
import com.gamehub.config.exception.model.GamehubConflictException;
import com.gamehub.config.exception.model.GamehubNotFoundException;
import com.gamehub.mappers.ParticipantsMapper;
import com.gamehub.persistance.entity.ParticipantsEntity;
import com.gamehub.persistance.repository.GamePostsRepository;
import com.gamehub.persistance.repository.ParticipantsRepository;
import com.gamehub.persistance.repository.UserRepository;
import com.gamehub.service.date.DateTimeServiceWrapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@AllArgsConstructor
public class ParticipantsServiceImpl implements ParticipantsService {

    private final ParticipantsRepository participantsRepository;
    private final UserRepository userRepository;
    private final GamePostsRepository gamePostsRepository;
    private final ParticipantsMapper participantsMapper;
    private final DateTimeServiceWrapper dateTimeServiceWrapper;

    @Transactional
    @Override
    public List<ParticipantsResponseModel> getAll() {
        return participantsRepository.findAll().stream()
                .map(participantsMapper::toParticipantsModel)
                .collect(Collectors.toList());
    }

    @Transactional
    @Override
    public ParticipantsResponseModel createParticipant(Long userId, ParticipantsRequestModel participantModel) {
        // Check if user is already participating in this game
        if (participantsRepository.existsByUserIdAndGamePostId(userId, participantModel.getGamePostId())) {
            throw new GamehubBadRequestException(ErrorType.PARTICIPANT_ALREADY_EXISTS);
        }

        ParticipantsEntity participantsEntity = participantsMapper.toParticipantsEntity(participantModel);

        var userEntity = userRepository.findById(userId)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.USER_NOT_FOUND));
        var gamePost = gamePostsRepository.findById(participantModel.getGamePostId())
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.GAME_POST_NOT_FOUND));

        participantsEntity.setUser(userEntity);
        participantsEntity.setGamePost(gamePost);
        participantsEntity.setStatus(participantModel.getStatus());
        participantsEntity.setJoinedAt(dateTimeServiceWrapper.now());
        participantsEntity.setIsHost(participantModel.getIsHost() != null ? participantModel.getIsHost() : false);

        return participantsMapper.toParticipantsModel(participantsRepository.save(participantsEntity));
    }

    @Transactional
    @Override
    public ParticipantsResponseModel updateParticipant(Long participantId, ParticipantsRequestModel participantModel) {
        ParticipantsEntity existingParticipant = getParticipantsById(participantId);

        participantsMapper.updateParticipantsEntity(existingParticipant, participantModel);

        return participantsMapper.toParticipantsModel(participantsRepository.save(existingParticipant));
    }

    @Transactional
    @Override
    public void delete(Long id) {

    }

    private ParticipantsEntity getParticipantsById(Long id) {
        return participantsRepository.findById(id)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.PARTICIPANT_NOT_FOUND));
    }
}
