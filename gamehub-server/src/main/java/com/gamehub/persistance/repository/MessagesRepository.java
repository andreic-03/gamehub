package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.MessagesEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MessagesRepository extends JpaRepository<MessagesEntity, Long> {
}
