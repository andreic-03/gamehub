package com.gamehub.persistance.repository;

import com.gamehub.persistance.entity.ParticipantsEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ParticipantsRepository extends JpaRepository<ParticipantsEntity, Long> {
}
