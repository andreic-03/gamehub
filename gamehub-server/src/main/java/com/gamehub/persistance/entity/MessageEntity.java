package com.gamehub.persistance.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "messages")
@Getter
@Setter
@NoArgsConstructor
public class MessageEntity extends AuditingEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long messageId;

    @ManyToOne
    @JoinColumn(name = "game_post_id", nullable = false)
    private GamePostsEntity gamePost;

    @ManyToOne
    @JoinColumn(name = "sender_user_id", nullable = false)
    private UserEntity senderUser;

    @Column(nullable = false)
    private String messageContent;
}
