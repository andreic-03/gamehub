package com.gamehub.api.model.general;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;

@AllArgsConstructor(access= AccessLevel.PRIVATE)
public final class Constants {

    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_USER = "USER";

    public static final String API_AUTH = "/auth";

    public static final String API_USERS = "/user";
    public static final String API_ADMIN_USERS = "/user/admin";
    public static final String API_ROLES = "/role";
    public static final String API_GAME_POSTS = "/game-posts";
    public static final String API_GAMES = "/games";
    public static final String API_PARTICIPANTS = "/participants";
    public static final String API_REVIEWS = "/reviews";
    public static final String API_MESSAGES = "/messages";

    public static final String AUTHORIZATION_HEADER_NAME = "Authorization";
    public static final String ACCESS_TOKEN_PREFIX_NAME = "Bearer";

    // If we will add pagination
//    public static final String DEFAULT_PAGE_NUMBER = "0";
//    public static final String DEFAULT_PAGE_SIZE = "10";
//    public static final String DEFAULT_SORT_BY = "id";
//    public static final String DEFAULT_SORT_DIRECTION = "ASC";
//
//    public static final String DEFAULT_ACCEPT_LANGUAGE = "en";
}
