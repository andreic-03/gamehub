package com.gamehub.service.gameposts;

import com.gamehub.api.model.gameposts.GamePostsRequestModel;
import com.gamehub.api.model.gameposts.GamePostsResponseModel;
import com.gamehub.api.model.participants.ParticipantsRequestModel;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubNotFoundException;
import com.gamehub.mappers.GamePostsMapper;
import com.gamehub.persistance.entity.GamePostsEntity;
import com.gamehub.persistance.entity.ParticipantsEntity;
import com.gamehub.persistance.repository.GamePostsRepository;
import com.gamehub.persistance.repository.GamesRepository;
import com.gamehub.persistance.repository.ParticipantsRepository;
import com.gamehub.persistance.repository.UserRepository;
import com.gamehub.service.participants.ParticipantsService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@AllArgsConstructor
public class GamePostsServiceImpl implements GamePostsService {

    private final GamePostsRepository gamePostsRepository;
    private final GamesRepository gameRepository;
    private final UserRepository userRepository;
    private final GamePostsMapper gamePostsMapper;
    private final ParticipantsService participantsService;
    private final ParticipantsRepository participantsRepository;

    @Transactional
    @Override
    public GamePostsResponseModel createGamePost(Long hostId, GamePostsRequestModel gamePostsModel) {
        GamePostsEntity gamePostsEntity = gamePostsMapper.toGamePostsEntity(gamePostsModel);

        var hostUserEntity = userRepository.findById(hostId)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.USER_NOT_FOUND));

        var gameEntity = gameRepository.findById(gamePostsModel.getGameId())
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.GAME_NOT_FOUND));

        gamePostsEntity.setHostUser(hostUserEntity);
        gamePostsEntity.setGame(gameEntity);

        // Save the game post first to get the generated ID
        GamePostsEntity savedGamePost = gamePostsRepository.save(gamePostsEntity);
        
        // Automatically add the host as a participant
        ParticipantsRequestModel hostParticipant = new ParticipantsRequestModel();
        hostParticipant.setGamePostId(savedGamePost.getPostId());
        hostParticipant.setStatus(ParticipantsEntity.Status.JOINED);
        hostParticipant.setIsHost(true);
        
        participantsService.createParticipant(hostId, hostParticipant);
        
        log.info("Game post created with ID: {} and host {} automatically added as participant", 
                savedGamePost.getPostId(), hostId);

        return toGamePostsModelWithParticipantCount(savedGamePost);
    }

    @Transactional
    @Override
    public GamePostsResponseModel updateGamePost(Long gamePostId, GamePostsRequestModel gamePostsModel) {
        GamePostsEntity existingGamePost = getGamePostById(gamePostId);

        gamePostsMapper.updateGamePostEntity(existingGamePost, gamePostsModel);

        return toGamePostsModelWithParticipantCount(gamePostsRepository.save(existingGamePost));
    }

    @Transactional
    @Override
    public void delete(Long id) {
        try {
            gamePostsRepository.deleteById(id);
        } catch (EmptyResultDataAccessException ex) {
            log.error("Game post not found with id: {}", id);
            throw new GamehubNotFoundException(ErrorType.GAME_POST_NOT_FOUND);
        }
    }

    @Transactional
    @Override
    public List<GamePostsResponseModel> findGamePostsNearby(Double latitude, Double longitude, Double rangeInKm) {
        return gamePostsRepository.findNearbyGamePosts(latitude, longitude, rangeInKm).stream()
                .map(this::toGamePostsModelWithParticipantCount)
                .collect(Collectors.toList());
    }

    private GamePostsEntity getGamePostById(Long id) {
        return gamePostsRepository.findById(id)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.GAME_POST_NOT_FOUND));
    }

    /**
     * Convert GamePostsEntity to GamePostsResponseModel with participant count
     */
    private GamePostsResponseModel toGamePostsModelWithParticipantCount(GamePostsEntity gamePost) {
        GamePostsResponseModel responseModel = gamePostsMapper.toGamePostsModel(gamePost);
        
        // Get participant count for this game post
        Long participantCount = participantsRepository.countByGamePostId(gamePost.getPostId());
        responseModel.setCurrentParticipantCount(participantCount.intValue());
        
        return responseModel;
    }
}
