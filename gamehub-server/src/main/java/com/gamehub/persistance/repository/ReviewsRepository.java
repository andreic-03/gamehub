package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.ReviewsEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface ReviewsRepository extends JpaRepository<ReviewsEntity, Long> {

    @Query("SELECT AVG(r.rating) FROM ReviewsEntity r WHERE r.reviewedUser.id = :userId")
    Double findAverageRatingByUserId(Long userId);
}
