package com.gamehub.api;

import com.gamehub.api.model.gameposts.GamePostsRequestModel;
import com.gamehub.api.model.gameposts.GamePostsResponseModel;
import com.gamehub.config.security.model.AppUserPrincipal;
import com.gamehub.service.gameposts.GamePostsService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import static com.gamehub.api.model.general.Constants.*;

@RestController
@RequestMapping(API_GAME_POSTS)
@AllArgsConstructor
public class GamePostsController {

    private GamePostsService gamePostsService;

    @PostMapping
    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    @ResponseStatus(HttpStatus.CREATED)
    public GamePostsResponseModel createGamePost(@AuthenticationPrincipal AppUserPrincipal user,
                                                 @RequestBody @Valid final GamePostsRequestModel gamePostsModel) {
        return gamePostsService.createGamePost(user.getUserEntity().getId(), gamePostsModel);
    }

    @PutMapping("/{id}")
    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    public GamePostsResponseModel updateGamePost(@PathVariable("id") final Long id,
                                                 @RequestBody @Valid final GamePostsRequestModel gamePostsModel){
        return gamePostsService.updateGamePost(id, gamePostsModel);
    }

    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable("id") final Long id) {
        gamePostsService.delete(id);
    }
}
