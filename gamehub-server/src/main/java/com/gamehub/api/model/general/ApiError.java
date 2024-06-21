package com.gamehub.api.model.general;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.gamehub.config.exception.model.ErrorType;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Builder
@Setter
@Getter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiError {
    private String code;
    private String message;
    private List<String> details;
    private ErrorType errorType;
}
