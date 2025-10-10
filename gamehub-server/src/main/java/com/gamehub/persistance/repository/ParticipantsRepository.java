package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.ParticipantsEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ParticipantsRepository extends JpaRepository<ParticipantsEntity, Long> {
    
    /**
     * Check if a user is already participating in a specific game post
     * @param userId The user ID
     * @param gamePostId The game post ID
     * @return Optional containing the existing participation if found
     */
    @Query("SELECT p FROM ParticipantsEntity p WHERE p.user.id = :userId AND p.gamePost.postId = :gamePostId")
    Optional<ParticipantsEntity> findByUserIdAndGamePostId(@Param("userId") Long userId, @Param("gamePostId") Long gamePostId);
    
    /**
     * Check if a user is already participating in a specific game post
     * @param userId The user ID
     * @param gamePostId The game post ID
     * @return true if user is already participating, false otherwise
     */
    @Query("SELECT COUNT(p) > 0 FROM ParticipantsEntity p WHERE p.user.id = :userId AND p.gamePost.postId = :gamePostId")
    boolean existsByUserIdAndGamePostId(@Param("userId") Long userId, @Param("gamePostId") Long gamePostId);
    
    /**
     * Count the number of participants for a specific game post
     * @param gamePostId The game post ID
     * @return The number of participants
     */
    @Query("SELECT COUNT(p) FROM ParticipantsEntity p WHERE p.gamePost.postId = :gamePostId")
    Long countByGamePostId(@Param("gamePostId") Long gamePostId);
}
