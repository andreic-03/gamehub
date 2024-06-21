package com.gamehub.config.exception.model;

import java.util.List;

public class GamehubConflictException extends GamehubException {

    public GamehubConflictException(ErrorType errorType) {
        super(errorType);
    }

    public GamehubConflictException(ErrorType errorType, List<String> errorArgs) {
        super(errorType, errorArgs);
    }
}
