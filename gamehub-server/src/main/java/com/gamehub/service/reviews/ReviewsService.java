package com.gamehub.service.reviews;

import com.gamehub.api.model.reviews.AverageRatingResponseModel;
import com.gamehub.api.model.reviews.ReviewsRequestModel;
import com.gamehub.api.model.reviews.ReviewsResponseModel;

public interface ReviewsService {
    ReviewsResponseModel createReview(Long reviewerUserId, ReviewsRequestModel reviewsModel);
    AverageRatingResponseModel getAverageRatingForUser(Long userId);
}
