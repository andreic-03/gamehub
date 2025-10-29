package com.gamehub.api;

import com.gamehub.api.model.participants.ParticipantsRequestModel;
import com.gamehub.api.model.participants.ParticipantsResponseModel;
import com.gamehub.config.security.model.AppUserPrincipal;
import com.gamehub.service.participants.ParticipantsService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.gamehub.api.model.general.Constants.*;

@RestController
@RequestMapping(API_PARTICIPANTS)
@AllArgsConstructor
public class ParticipantsController {

    private final ParticipantsService participantsService;

    @GetMapping
    public List<ParticipantsResponseModel> getAll() {
        return participantsService.getAll();
    }

    @PostMapping
    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    @ResponseStatus(HttpStatus.CREATED)
    public ParticipantsResponseModel createParticipant(@AuthenticationPrincipal AppUserPrincipal user,
                                                       @RequestBody @Valid final ParticipantsRequestModel participantsModel) {
        return participantsService.createParticipant(user.getUserEntity().getId(), participantsModel);
    }

    @PutMapping("/{id}")
    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    public ParticipantsResponseModel updateParticipant(@PathVariable("id") final Long id,
                                                       @RequestBody @Valid final ParticipantsRequestModel participantsModel) {
        return participantsService.updateParticipant(id, participantsModel);
    }

    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable("id") final Long id) {
        participantsService.delete(id);
    }

    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    @GetMapping("/is-joined")
    public boolean isJoined(@AuthenticationPrincipal AppUserPrincipal user,
                            @RequestParam("gamePostId") final Long gamePostId) {
        return participantsService.isUserJoined(user.getUserEntity().getId(), gamePostId);
    }

    @RolesAllowed({ROLE_ADMIN, ROLE_USER})
    @DeleteMapping("/leave")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void leaveGame(@AuthenticationPrincipal AppUserPrincipal user,
                          @RequestParam("gamePostId") final Long gamePostId) {
        participantsService.leaveGame(user.getUserEntity().getId(), gamePostId);
    }
}
