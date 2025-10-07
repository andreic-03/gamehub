import 'dart:async';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../core/utils/error_util.dart';
import '../../core/viewmodels/base_view_model.dart';
import '../../models/game/games_response_model.dart';
import '../../models/game_post/game_post_request_model.dart';
import '../../services/game/game_service.dart';
import '../../services/game_post/game_post_service.dart';

@injectable
class CreateGamePostViewModel extends BaseViewModel {
  final GamePostService _gamePostService;
  final GameService _gameService;

  CreateGamePostViewModel(this._gamePostService, this._gameService);

  Timer? _searchDebounce;

  Future<DateTime?> selectDate(BuildContext context, DateTime current, TimeOfDay selectedTime) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return null;
    return DateTime(picked.year, picked.month, picked.day, selectedTime.hour, selectedTime.minute);
  }

  Future<TimeOfDay?> selectTime(BuildContext context, TimeOfDay current) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: current,
    );
    return picked;
  }

  Future<void> createGamePost({
    required BuildContext context,
    required TextEditingController gameIdController,
    required TextEditingController locationController,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
    required DateTime scheduledDate,
    required TextEditingController maxParticipantsController,
    required TextEditingController descriptionController,
  }) async {
    await runBusyFuture(() async {
      // Ensure date is in the future
      final now = DateTime.now();
      if (scheduledDate.isBefore(now)) {
        ErrorUtil.showErrorDialog(
          context,
          {
            'code': 'VALIDATION_ERROR',
            'message': 'Invalid Date',
            'details': ['Selected date must be in the future'],
            'errorType': 'VALIDATION_ERROR'
          },
        );
        return;
      }

      try {
        final request = GamePostRequestModel(
          gameId: int.parse(gameIdController.text),
          location: locationController.text,
          latitude: double.parse(latitudeController.text),
          longitude: double.parse(longitudeController.text),
          scheduledDate: scheduledDate,
          maxParticipants: int.parse(maxParticipantsController.text),
          description: descriptionController.text.isEmpty ? null : descriptionController.text,
        );

        await _gamePostService.createGamePost(request);
      } catch (e) {
        ErrorUtil.showErrorDialog(context, e);
      }
    });
  }

  void onGameNameChanged(
    String query, {
    required void Function(bool) setSearching,
    required void Function(List<GamesResponseModel>) setSuggestions,
    required VoidCallback clearSelection,
  }) {
    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      setSearching(false);
      setSuggestions([]);
      clearSelection();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      setSearching(true);
      try {
        final results = await _gameService.getGameByName(query);
        setSuggestions(results);
      } catch (_) {
        setSuggestions([]);
      } finally {
        setSearching(false);
      }
    });
  }

  void selectGame(
    GamesResponseModel game, {
    required TextEditingController gameNameController,
    required TextEditingController gameIdController,
    required void Function(List<GamesResponseModel>) setSuggestions,
  }) {
    gameNameController.text = game.gameName;
    gameIdController.text = game.gameId.toString();
    setSuggestions([]);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}

