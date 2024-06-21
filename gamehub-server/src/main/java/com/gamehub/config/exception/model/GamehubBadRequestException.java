package com.gamehub.config.exception.model;

import java.util.List;

public class GamehubBadRequestException extends GamehubException {

    public GamehubBadRequestException(ErrorType errorType) {
        super(errorType);
    }

    public GamehubBadRequestException(ErrorType errorType, List<String> errorArgs) {
        super(errorType, errorArgs);
    }
}
