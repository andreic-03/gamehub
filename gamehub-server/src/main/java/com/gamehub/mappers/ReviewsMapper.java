package com.gamehub.mappers;

import com.gamehub.api.model.reviews.ReviewsRequestModel;
import com.gamehub.api.model.reviews.ReviewsResponseModel;
import com.gamehub.persistance.entity.ReviewsEntity;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface ReviewsMapper {

    @Mapping(source = "reviewerUser.id", target = "reviewerUserId")
    @Mapping(source = "reviewedUser.id", target = "reviewedUserId")
    @Mapping(source = "gamePost.postId", target = "gamePostId")
    ReviewsResponseModel toReviewsModel(ReviewsEntity reviews);

    @Mapping(target = "reviewId", ignore = true)
    @Mapping(target = "createdOn", ignore = true)
    @Mapping(target = "updatedOn", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    ReviewsEntity toReviewsEntity(ReviewsRequestModel reviews);
}
