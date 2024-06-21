package com.gamehub.config.exception.model;

import java.util.List;

public class GamehubNotFoundException extends GamehubException {

    public GamehubNotFoundException(ErrorType errorType) {
        super(errorType);
    }

    public GamehubNotFoundException(ErrorType errorType, List<String> errorArgs) {
        super(errorType, errorArgs);
    }
}
