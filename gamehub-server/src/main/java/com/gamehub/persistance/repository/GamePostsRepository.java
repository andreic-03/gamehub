package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.GamePostsEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface GamePostsRepository extends JpaRepository<GamePostsEntity, Long> {

    @Query("SELECT g FROM GamePostsEntity g " +
            "WHERE (6371 * acos(cos(radians(:latitude)) * cos(radians(g.latitude)) * cos(radians(g.longitude) - radians(:longitude)) + sin(radians(:latitude)) * sin(radians(g.latitude)))) <= :rangeInKm " +
            "ORDER BY g.scheduledDate ASC")
    List<GamePostsEntity> findNearbyGamePosts(@Param("latitude") double latitude,
                                              @Param("longitude") double longitude,
                                              @Param("rangeInKm") double rangeInKm);
}
