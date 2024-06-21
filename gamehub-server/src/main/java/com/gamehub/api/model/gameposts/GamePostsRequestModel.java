package com.gamehub.api.model.gameposts;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class GamePostsRequestModel {
    @NotNull
    private Long gameId;

    @NotBlank
    private String location;

    @NotNull
    @Future
    private LocalDateTime scheduledDate;

    @NotNull
    private Integer maxParticipants;

    private String description;
}
