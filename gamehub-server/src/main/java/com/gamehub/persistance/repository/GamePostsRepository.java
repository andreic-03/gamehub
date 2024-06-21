package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.GamePostsEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GamePostsRepository extends JpaRepository<GamePostsEntity, Long> {

}
