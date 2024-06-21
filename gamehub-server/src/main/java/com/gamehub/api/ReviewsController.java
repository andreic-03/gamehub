package com.gamehub.api;

import com.gamehub.api.model.reviews.AverageRatingResponseModel;
import com.gamehub.api.model.reviews.ReviewsRequestModel;
import com.gamehub.api.model.reviews.ReviewsResponseModel;
import com.gamehub.config.security.model.AppUserPrincipal;
import com.gamehub.service.reviews.ReviewsService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import static com.gamehub.api.model.general.Constants.*;

@RestController
@RequestMapping(API_REVIEWS)
@AllArgsConstructor
public class ReviewsController {

    private final ReviewsService reviewsService;

    @PostMapping
    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    @ResponseStatus(HttpStatus.CREATED)
    public ReviewsResponseModel createReview(@AuthenticationPrincipal AppUserPrincipal user,
                                               @RequestBody @Valid final ReviewsRequestModel reviewsModel) {
        return reviewsService.createReview(user.getUserEntity().getId(), reviewsModel);
    }

    @GetMapping("/average-rating/{userId}")
    public AverageRatingResponseModel getAverageRatingForUser(@PathVariable Long userId) {
        return reviewsService.getAverageRatingForUser(userId);
    }
}
