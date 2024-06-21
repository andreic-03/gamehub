package com.gamehub.service.reviews;

import com.gamehub.api.model.reviews.AverageRatingResponseModel;
import com.gamehub.api.model.reviews.ReviewsRequestModel;
import com.gamehub.api.model.reviews.ReviewsResponseModel;
import com.gamehub.config.exception.model.ErrorType;
import com.gamehub.config.exception.model.GamehubNotFoundException;
import com.gamehub.mappers.ReviewsMapper;
import com.gamehub.persistance.entity.ReviewsEntity;
import com.gamehub.persistance.repository.GamePostsRepository;
import com.gamehub.persistance.repository.ReviewsRepository;
import com.gamehub.persistance.repository.UserRepository;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@AllArgsConstructor
public class ReviewsServiceImpl implements ReviewsService {

    private final ReviewsRepository reviewsRepository;
    private final UserRepository userRepository;
    private final GamePostsRepository gamePostsRepository;
    private final ReviewsMapper reviewsMapper;

    @Transactional
    @Override
    public ReviewsResponseModel createReview(Long reviewerUserId, ReviewsRequestModel reviewsModel) {
        ReviewsEntity reviewsEntity = reviewsMapper.toReviewsEntity(reviewsModel);

        var reviewerUser = userRepository.findById(reviewerUserId)
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.USER_NOT_FOUND));
        var reviewedUser = userRepository.findById(reviewsModel.getReviewedUserId())
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.USER_NOT_FOUND));
        var gamePost = gamePostsRepository.findById(reviewsModel.getGamePostId())
                .orElseThrow(() -> new GamehubNotFoundException(ErrorType.GAME_POST_NOT_FOUND));

        reviewsEntity.setReviewerUser(reviewerUser);
        reviewsEntity.setReviewedUser(reviewedUser);
        reviewsEntity.setGamePost(gamePost);

        return reviewsMapper.toReviewsModel(reviewsRepository.save(reviewsEntity));
    }

    @Transactional
    @Override
    public AverageRatingResponseModel getAverageRatingForUser(Long userId) {
        Double averageRating = reviewsRepository.findAverageRatingByUserId(userId);
        AverageRatingResponseModel averageRatingResponseModel = new AverageRatingResponseModel();

        averageRatingResponseModel.setAverageRating(averageRating != null ? averageRating : 0.0);

        return averageRatingResponseModel;
    }
}
