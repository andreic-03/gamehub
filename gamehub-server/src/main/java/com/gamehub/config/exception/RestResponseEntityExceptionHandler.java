package com.gamehub.config.exception;

import com.gamehub.api.model.general.ApiError;
import com.gamehub.config.exception.model.*;
import com.gamehub.service.internationalization.TranslateService;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.TypeMismatchException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpMediaTypeNotAcceptableException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestHeaderException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.ServletRequestBindingException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.multipart.support.MissingServletRequestPartException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import static com.gamehub.config.exception.model.ErrorType.*;

@Slf4j
@AllArgsConstructor
@ControllerAdvice
public class RestResponseEntityExceptionHandler extends ResponseEntityExceptionHandler {
    private final TranslateService translateService;

    @ExceptionHandler(value = {GamehubNotFoundException.class})
    protected ResponseEntity<Object> handleNotFoundException(GamehubNotFoundException ex, WebRequest request) {
        return handleFolkException(ex, HttpStatus.NOT_FOUND, request);
    }

    @ExceptionHandler(value = {GamehubBadRequestException.class})
    protected ResponseEntity<Object> handleBadRequestException(GamehubBadRequestException ex, WebRequest request) {
        return handleFolkException(ex, HttpStatus.BAD_REQUEST, request);
    }

    @ExceptionHandler(value = {GamehubUnauthorizedException.class})
    protected ResponseEntity<Object> handleUnauthorizedException(GamehubUnauthorizedException ex, WebRequest request) {
        return handleFolkException(ex, HttpStatus.UNAUTHORIZED, request);
    }

    @ExceptionHandler(value = {GamehubForbiddenException.class})
    protected ResponseEntity<Object> handleForbiddenException(GamehubForbiddenException ex, WebRequest request) {
        return handleFolkException(ex, HttpStatus.FORBIDDEN, request);
    }

    @ExceptionHandler(value = {GamehubConflictException.class})
    protected ResponseEntity<Object> handleConflictException(GamehubConflictException ex, WebRequest request) {
        return handleFolkException(ex, HttpStatus.CONFLICT, request);
    }

    @ExceptionHandler(value = {GamehubException.class})
    protected ResponseEntity<Object> handleFolkException(GamehubException ex, WebRequest request) {
        return handleFolkException(ex, HttpStatus.INTERNAL_SERVER_ERROR, request);
    }

    @ExceptionHandler(value = {Throwable.class})
    protected ResponseEntity<Object> handleThrowable(Exception ex, WebRequest request) {
        log.error("Exception not cached", ex);
        return handleInvalidRequestOrInternalErrorException(ex, INTERNAL_SERVER_ERROR, Collections.emptyList(), HttpStatus.INTERNAL_SERVER_ERROR, request);
    }

    /**
     * Handles unsupported HTTP Request Method.
     */
    @Override
    protected ResponseEntity<Object> handleHttpRequestMethodNotSupported(HttpRequestMethodNotSupportedException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        return handleInvalidRequestOrInternalErrorException(ex, REQUEST_METHOD_NOT_SUPPORTED, Collections.singletonList(ex.getMethod()), HttpStatus.METHOD_NOT_ALLOWED, request);
    }

    /**
     * Handles unsupported Media Type.
     */
    @Override
    protected ResponseEntity<Object> handleHttpMediaTypeNotSupported(HttpMediaTypeNotSupportedException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        return handleInvalidRequestOrInternalErrorException(ex, UNSUPPORTED_MEDIA_TYPE, Collections.emptyList(), HttpStatus.UNSUPPORTED_MEDIA_TYPE, request);
    }

    /**
     * Handles not acceptable Media Type.
     */

    @Override
    protected ResponseEntity<Object> handleHttpMediaTypeNotAcceptable(HttpMediaTypeNotAcceptableException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        return handleInvalidRequestOrInternalErrorException(ex, NOT_ACCEPTABLE_MEDIA_TYPE, Collections.emptyList(), HttpStatus.NOT_ACCEPTABLE, request);
    }

    /**
     * Handles missing query parameter.
     */
    @Override
    protected ResponseEntity<Object> handleMissingServletRequestParameter(MissingServletRequestParameterException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        return handleInvalidRequestOrInternalErrorException(ex, MISSING_QUERY_PARAM, Collections.singletonList(ex.getParameterName()), HttpStatus.BAD_REQUEST, request);
    }

    /**
     * Handles type mismatch (e.g. sending a string instead of a int to a path variable).
     */
    @Override
    protected ResponseEntity<Object> handleTypeMismatch(TypeMismatchException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        return handleInvalidRequestOrInternalErrorException(ex, TYPE_MISMATCH, Collections.singletonList(ex.getPropertyName()), HttpStatus.BAD_REQUEST, request);
    }

    /**
     * Handles situations when the part of a "multipart/form-data" request identified by its name cannot be found.
     */
    @Override
    protected ResponseEntity<Object> handleMissingServletRequestPart(MissingServletRequestPartException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        return handleInvalidRequestOrInternalErrorException(ex, MULTIPART_CANNOT_BE_FOUND, Collections.singletonList(ex.getRequestPartName()), HttpStatus.BAD_REQUEST, request);
    }

    /**
     * Handles missing request header.
     */
    @Override
    protected ResponseEntity<Object> handleServletRequestBindingException(
            ServletRequestBindingException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        if (ex instanceof MissingRequestHeaderException) {
            return handleInvalidRequestOrInternalErrorException(ex, MISSING_REQUEST_HEADER, Collections.singletonList(((MissingRequestHeaderException) ex).getHeaderName()), HttpStatus.BAD_REQUEST, request);
        } else {
            // error details won't be translated
            return handleFrameworkSpecificException(ex, BAD_REQUEST, HttpStatus.BAD_REQUEST, request);
        }
    }

    /**
     * Handles invalid request body (e.g. missing request body, invalid tag, malformed xml/json, invalid value, etc.).
     */
    @Override
    protected ResponseEntity<Object> handleHttpMessageNotReadable(HttpMessageNotReadableException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        // error details won't be translated
        return handleFrameworkSpecificException(ex, BAD_REQUEST, HttpStatus.BAD_REQUEST, request);
    }

    /**
     * Handles request field validation exceptions (e.g. {@link NotEmpty}, {@link NotNull}, {@link NotBlank},
     * {@link Min}, {@link Max}).
     *
     * @apiNote: the error messages come already translated from the framework
     */
    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        //get our actual exception message
        final var errors = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(error -> error.getField() + " " + error.getDefaultMessage())
                .collect(Collectors.toList());
        ex.getBindingResult()
                .getGlobalErrors()
                .stream()
                .map(error -> error.getObjectName() + " " + error.getDefaultMessage())
                .forEach(errors::add);

        final var errorBody = translateService.translate(INVALID_PARAMETERS, Collections.emptyList(), errors);
        return handleExceptionInternal(ex, errorBody, new HttpHeaders(), HttpStatus.BAD_REQUEST, request);
    }

    /**
     * Handles a {@link GamehubException}.
     *
     * @param ex      - the raised exception.
     * @param status  - the http status of the response.
     * @param request - the original request.
     * @return a wrapper over a {@link ApiError} object containing the error response.
     */
    private ResponseEntity<Object> handleFolkException(GamehubException ex, HttpStatus status, WebRequest request) {
        final ApiError errorBody = translateService.translate(ex.getErrorType(), ex.getErrorArgs());
        return handleExceptionInternal(ex, errorBody, new HttpHeaders(), status, request);
    }

    /**
     * Handles an exception raised due to an invalid request or an internal server error.
     *
     * @param ex                - the raised exception
     * @param errorType         - the error type to which the exception will be mapped.
     * @param placeholderValues - the values to replace the translation placeholders.
     * @param httpStatus        - the http status of the response.
     * @param request           - the original request.
     * @return a wrapper over a {@link ApiError} object containing the error response.
     */
    private ResponseEntity<Object> handleInvalidRequestOrInternalErrorException(Exception ex, ErrorType errorType, List<String> placeholderValues, HttpStatus httpStatus, WebRequest request) {
        final ApiError errorBody = translateService.translate(errorType, placeholderValues);
        return handleExceptionInternal(ex, errorBody, new HttpHeaders(), httpStatus, request);
    }

    /**
     * Handles a framework specific exception.
     *
     * @param ex         - the raised exception.
     * @param errorType  - the error type to which the framework exception will be mapped.
     * @param httpStatus - the http status of the response.
     * @param request    - the original request.
     * @return a wrapper over a {@link ApiError} object containing the error response.
     */
    private ResponseEntity<Object> handleFrameworkSpecificException(Exception ex, ErrorType errorType, HttpStatus httpStatus, WebRequest request) {
        final ApiError errorBody = translateService.translate(errorType, Collections.emptyList(), ex.getMessage());
        return handleExceptionInternal(ex, errorBody, new HttpHeaders(), httpStatus, request);
    }
}