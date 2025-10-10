package com.gamehub.config.exception.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.ToString;

@Getter
@ToString
@AllArgsConstructor
public enum ErrorType {
    //User
    USER_NOT_FOUND("E2001", "No user found"),
    ROLE_NOT_FOUND("E2002", "Role not found"),
    OLD_PASSWORD_DID_NOT_MATCH("E2003", "Old password did not match"),

    //Games
    GAME_NOT_FOUND("E2100", "Game not found"),

    //GamePosts
    GAME_POST_NOT_FOUND("E2200", "Game post not found"),

    //Participants
    PARTICIPANT_NOT_FOUND("E2300", "Participant not found"),
    PARTICIPANT_ALREADY_EXISTS("E2301", "User is already participating in this game"),

    //General
    INTERNAL_SERVER_ERROR("E9000", "Something unexpected happened"),
    BAD_REQUEST("E9100", "Bad request"),
    INVALID_PARAMETERS("E9101", "Invalid parameters"),
    UNSUPPORTED_MEDIA_TYPE("E9102", "Unsupported Media Type"),
    NOT_ACCEPTABLE_MEDIA_TYPE("E9103", "Not Acceptable Media Type"),
    MISSING_REQUEST_HEADER("E9104", "Missing request header: {0}"),
    MISSING_QUERY_PARAM("E9105", "Missing query param: {0}"),
    REQUEST_METHOD_NOT_SUPPORTED("E9106", "Request method {0} not supported"),
    TYPE_MISMATCH("E9107", "Type mismatch: {0}"),
    MULTIPART_CANNOT_BE_FOUND("E9108", "The part {0} of the multipart/form-data request identified cannot be found"),
    AUTHORIZATION("E9109", "Authorization error"),
    AUTHENTICATION("E9110", "Authentication error")
    ;

    private final String errorCode;
    private final String defaultErrorMessage;
}
