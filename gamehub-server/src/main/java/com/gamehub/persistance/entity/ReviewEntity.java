package com.gamehub.persistance.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "reviews")
@Getter
@Setter
@NoArgsConstructor
public class ReviewEntity extends AuditingEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer reviewId;

    @ManyToOne
    @JoinColumn(name = "reviewer_user_id", nullable = false)
    private UserEntity reviewerUser;

    @ManyToOne
    @JoinColumn(name = "reviewed_user_id", nullable = false)
    private UserEntity reviewedUser;

    @ManyToOne
    @JoinColumn(name = "game_post_id", nullable = false)
    private GamePostsEntity gamePost;

    @Column(nullable = false)
    private Integer rating;

    private String reviewText;
}
