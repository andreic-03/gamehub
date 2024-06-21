package com.gamehub.api.model.reviews;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewsRequestModel {
    @NotNull
    private Long reviewedUserId;

    @NotNull
    private Long gamePostId;

    @NotNull
    private Integer rating;

    private String reviewText;
}
