package com.gamehub.config.exception.model;

import java.util.List;

public class GamehubUnauthorizedException extends GamehubException {

    public GamehubUnauthorizedException(ErrorType errorType) {
        super(errorType);
    }

    public GamehubUnauthorizedException(ErrorType errorType, List<String> errorArgs) {
        super(errorType, errorArgs);
    }
}
