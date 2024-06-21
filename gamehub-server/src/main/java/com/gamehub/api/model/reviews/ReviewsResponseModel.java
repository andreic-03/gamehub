package com.gamehub.api.model.reviews;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewsResponseModel {
    private Long reviewId;
    private Long reviewerUserId;
    private Long reviewedUserId;
    private Long gamePostId;
    private Integer rating;
    private String reviewText;
}
