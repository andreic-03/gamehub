package com.gamehub.service.internationalization;

import com.gamehub.api.model.general.ApiError;
import com.gamehub.config.exception.model.ErrorType;

import java.util.List;

public interface TranslateService {
    ApiError translate(final ErrorType errorType);

    ApiError translate(final ErrorType errorType, final List<String> args);

    ApiError translate(final ErrorType errorType, final List<String> args, final String details);
    ApiError translate(final ErrorType errorType, final List<String> args, final List<String> details);
}
