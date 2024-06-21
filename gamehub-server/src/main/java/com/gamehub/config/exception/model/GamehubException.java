package com.gamehub.config.exception.model;

import lombok.Getter;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static com.gamehub.config.exception.model.ErrorType.INTERNAL_SERVER_ERROR;

@Getter
public class GamehubException extends RuntimeException {
    private ErrorType errorType;
    private List<String> errorArgs;

    public GamehubException() {
        super(INTERNAL_SERVER_ERROR.getDefaultErrorMessage());
        this.errorType = INTERNAL_SERVER_ERROR;
        this.errorArgs = new ArrayList<>();
    }

    protected GamehubException(ErrorType errorType) {
        super(Optional.ofNullable(errorType)
                .map(ErrorType::getDefaultErrorMessage)
                .orElseGet(INTERNAL_SERVER_ERROR::getDefaultErrorMessage)
        );
        this.errorType = errorType;
        this.errorArgs = new ArrayList<>();
    }

    protected GamehubException(ErrorType errorType, List<String> errorArgs) {
        super(Optional.ofNullable(errorType)
                .map(ErrorType::getDefaultErrorMessage)
                .orElseGet(INTERNAL_SERVER_ERROR::getDefaultErrorMessage)
        );
        this.errorType = errorType;
        this.errorArgs = errorArgs;
    }
}
