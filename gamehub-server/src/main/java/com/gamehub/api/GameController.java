package com.gamehub.api;

import com.gamehub.api.model.games.GamesRequestModel;
import com.gamehub.api.model.games.GamesResponseModel;
import com.gamehub.service.games.GamesService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.gamehub.api.model.general.Constants.*;

@RestController
@RequestMapping(API_GAME)
@AllArgsConstructor
public class GameController {

    private GamesService gamesService;

    @GetMapping
    public List<GamesResponseModel> getAll() {
        return gamesService.getAll();
    }

    @PostMapping
    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    @ResponseStatus(HttpStatus.CREATED)
    public GamesResponseModel createGame(@RequestBody @Valid final GamesRequestModel gamesModel) {
        return gamesService.createGame(gamesModel);
    }

    @PutMapping("/{id}")
    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    public GamesResponseModel updateGame(@PathVariable("id") final Long id,
                                         @RequestBody @Valid final GamesRequestModel gamesModel){
        return gamesService.updateGame(id, gamesModel);
    }

    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable("id") final Long id) {
        gamesService.delete(id);
    }
}
