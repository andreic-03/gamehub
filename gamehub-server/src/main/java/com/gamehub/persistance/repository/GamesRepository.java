package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.GamesEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GamesRepository extends JpaRepository<GamesEntity, Long> {
}
