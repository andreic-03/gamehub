package com.gamehub.service.internationalization;

import com.gamehub.api.model.general.ApiError;
import com.gamehub.config.exception.model.ErrorType;
import lombok.AllArgsConstructor;
import org.springframework.context.MessageSource;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Service;

import java.text.MessageFormat;
import java.util.Collections;
import java.util.List;

@Service
@AllArgsConstructor
public class TranslateServiceImpl implements TranslateService {
    private final MessageSource messageSource;

    @Override
    public ApiError translate(ErrorType errorType) {
        return translate(errorType, Collections.emptyList());
    }

    @Override
    public ApiError translate(ErrorType errorType, List<String> args) {
        return translate(errorType, args, (String)null);
    }

    @Override
    public ApiError translate(ErrorType errorType, List<String> args, List<String> details) {
        return ApiError.builder()
                .code(errorType.getErrorCode())
                .message(extractErrorMessage(errorType, args))
                .details(details)
                .errorType(errorType)
                .build();
    }

    @Override
    public ApiError translate(ErrorType errorType, List<String> args, String details) {
        return translate(errorType, args, Collections.singletonList(details));
    }

    /**
     * Extracts the translated error message from an {@link ErrorType} object.
     *
     * @param errorType - the type of error to extract the message from.
     * @param args      - the arguments to be inserted in the message translation.
     * @return the translated message.
     */
    private String extractErrorMessage(ErrorType errorType, List<String> args) {
        try {
            return messageSource.getMessage(errorType.getErrorCode(), args.toArray(), LocaleContextHolder.getLocale());
        } catch (NoSuchMessageException noSuchMessageException) {
            return new MessageFormat(errorType.getDefaultErrorMessage()).format(args.toArray());
        }
    }
}
