package com.gamehub.service.gameposts;

import com.gamehub.api.model.gameposts.GamePostsRequestModel;
import com.gamehub.api.model.gameposts.GamePostsResponseModel;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubNotFoundException;
import com.gamehub.mappers.GamePostsMapper;
import com.gamehub.persistance.entity.GamePostsEntity;
import com.gamehub.persistance.repository.GamePostsRepository;
import com.gamehub.persistance.repository.GamesRepository;
import com.gamehub.persistance.repository.UserRepository;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@AllArgsConstructor
public class GamePostsServiceImpl implements GamePostsService {

    private final GamePostsRepository gamePostsRepository;
    private final GamesRepository gameRepository;
    private final UserRepository userRepository;
    private final GamePostsMapper gamePostsMapper;

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

        return gamePostsMapper.toGamePostsModel(gamePostsRepository.save(gamePostsEntity));
    }

    @Transactional
    @Override
    public GamePostsResponseModel updateGamePost(Long gamePostId, GamePostsRequestModel gamePostsModel) {
        GamePostsEntity existingGamePost = getGamePostById(gamePostId);

        gamePostsMapper.updateGamePostEntity(existingGamePost, gamePostsModel);

        return gamePostsMapper.toGamePostsModel(gamePostsRepository.save(existingGamePost));
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

    private GamePostsEntity getGamePostById(Long id) {
        return gamePostsRepository.findById(id)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.GAME_POST_NOT_FOUND));
    }
}
