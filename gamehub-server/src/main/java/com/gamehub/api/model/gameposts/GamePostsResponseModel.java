package com.gamehub.api.model.gameposts;


import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class GamePostsResponseModel {
    private Long postId;
    private Long hostUserId;
    private Long gameId;
    private String location;
    private Double latitude;
    private Double longitude;
    private LocalDateTime scheduledDate;
    private Integer maxParticipants;
    private String description;
}
