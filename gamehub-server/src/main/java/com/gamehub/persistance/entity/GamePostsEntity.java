package com.gamehub.persistance.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "game_posts")
@Getter
@Setter
@NoArgsConstructor
public class GamePostsEntity extends AuditingEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long postId;

    @ManyToOne
    @JoinColumn(name = "host_user_id", nullable = false)
    private UserEntity hostUser;

    @ManyToOne
    @JoinColumn(name = "game_id", nullable = false)
    private GamesEntity game;

    @Column(nullable = false)
    private String location;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Column(nullable = false)
    private LocalDateTime scheduledDate;

    @Column
    private Integer maxParticipants;

    @Column
    private String description;
}
