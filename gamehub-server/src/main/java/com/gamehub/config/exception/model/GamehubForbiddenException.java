package com.gamehub.config.exception.model;

import java.util.List;

public class GamehubForbiddenException extends GamehubException {

    public GamehubForbiddenException(ErrorType errorType) {
        super(errorType);
    }

    public GamehubForbiddenException(ErrorType errorType, List<String> errorArgs) {
        super(errorType, errorArgs);
    }
}
