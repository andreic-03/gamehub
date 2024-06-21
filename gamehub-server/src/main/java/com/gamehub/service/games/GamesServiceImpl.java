package com.gamehub.service.games;

import com.gamehub.api.model.games.GamesRequestModel;
import com.gamehub.api.model.games.GamesResponseModel;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubNotFoundException;
import com.gamehub.mappers.GamesMapper;
import com.gamehub.persistance.entity.GamesEntity;
import com.gamehub.persistance.repository.GamesRepository;
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
public class GamesServiceImpl implements GamesService {

    private final GamesRepository gamesRepository;
    private final GamesMapper gamesMapper;

    @Transactional
    @Override
    public List<GamesResponseModel> getAll() {
        return gamesRepository.findAll().stream()
                .map(gamesMapper::toGamesModel)
                .collect(Collectors.toList());
    }

    @Transactional
    @Override
    public GamesResponseModel createGame(GamesRequestModel gamesModel) {
        GamesEntity games = gamesMapper.toGamesEntity(gamesModel);

        return gamesMapper.toGamesModel(gamesRepository.save(games));
    }

    @Transactional
    @Override
    public GamesResponseModel updateGame(Long gameId, GamesRequestModel gamesModel) {
        GamesEntity existingGame = getGamePostById(gameId);

        gamesMapper.updateGamesEntity(existingGame, gamesModel);

        return gamesMapper.toGamesModel(gamesRepository.save(existingGame));
    }

    @Transactional
    @Override
    public void delete(Long id) {
        try {
            gamesRepository.deleteById(id);
        } catch (EmptyResultDataAccessException ex) {
            log.error("Game not found with id: {}", id);
            throw new GamehubNotFoundException(ErrorType.GAME_NOT_FOUND);
        }
    }

    private GamesEntity getGamePostById(Long id) {
        return gamesRepository.findById(id)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.GAME_NOT_FOUND));
    }
}
