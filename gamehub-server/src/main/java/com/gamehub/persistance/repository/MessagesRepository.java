package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.MessagesEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MessagesRepository extends JpaRepository<MessagesEntity, Long> {
    List<MessagesEntity> findByGamePost_PostIdOrderBySentAtAsc(Long postId);
}
