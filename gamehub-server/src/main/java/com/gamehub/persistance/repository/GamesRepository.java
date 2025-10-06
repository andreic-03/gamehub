package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.GamesEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface GamesRepository extends JpaRepository<GamesEntity, Long> {
    
    @Query("SELECT g FROM GamesEntity g WHERE LOWER(g.gameName) LIKE LOWER(CONCAT('%', :gameName, '%'))")
    List<GamesEntity> findByGameNameContainingIgnoreCase(@Param("gameName") String gameName);
}
