import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../config/injection.dart';
import '../../widgets/custom_toast.dart';
import '../../localization/localized_text.dart';
import '../../core/errors/api_error.dart';
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

  Future<bool> createGamePost({
    required BuildContext context,
    required TextEditingController gameIdController,
    required TextEditingController locationController,
    required double? latitude,
    required double? longitude,
    required DateTime scheduledDate,
    required TextEditingController maxParticipantsController,
    required TextEditingController descriptionController,
  }) async {
    return await runBusyFuture(() async {
      // Validate coordinates
      if (latitude == null || longitude == null) {
        CustomToast.showText(
          context,
          'create_game_post.select_location_on_map'.localized,
          backgroundColor: Colors.red,
        );
        return false;
      }

      // Ensure date is at least 2 hours in the future
      final now = DateTime.now();
      final minAllowed = now.add(const Duration(hours: 2));
      if (scheduledDate.isBefore(minAllowed)) {
        CustomToast.showText(
          context,
          'create_game_post.date_must_be_future'.localized,
          backgroundColor: Colors.red,
        );
        return false;
      }

      try {
        final request = GamePostRequestModel(
          gameId: int.parse(gameIdController.text),
          location: locationController.text,
          latitude: latitude!,
          longitude: longitude!,
          scheduledDate: scheduledDate,
          maxParticipants: int.parse(maxParticipantsController.text),
          description: descriptionController.text.isEmpty ? null : descriptionController.text,
        );

        await _gamePostService.createGamePost(request);
        return true;
      } catch (e) {
        String message;
        try {
          if (e is DioException) {
            final apiError = ApiError.fromDioError(e);
            message = apiError.message;
          } else if (e is ApiError) {
            message = e.message;
          } else {
            message = '${'create_game_post.error_creating'.localized}: $e';
          }
        } catch (_) {
          message = '${'create_game_post.error_creating'.localized}: $e';
        }
        CustomToast.showText(
          context,
          message,
          backgroundColor: Colors.red,
        );
        return false;
      }
    }) ?? false;
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

  Future<void> onGameFieldFocused({
    required void Function(bool) setSearching,
    required void Function(List<GamesResponseModel>) setSuggestions,
  }) async {
    setSearching(true);
    try {
      // Try using search endpoint with empty query; if server returns all or ignores, it'll work
      List<GamesResponseModel> results = [];
      try {
        results = await _gameService.getGameByName('');
      } catch (_) {}

      if (results.isEmpty) {
        // Fallback: raw GET to /games
        final dio = getIt<Dio>();
        final response = await dio.get('/games');
        final data = (response.data as List)
            .map((e) => GamesResponseModel.fromJson(e as Map<String, dynamic>))
            .toList();
        results = data;
      }

      setSuggestions(results);
    } catch (_) {
      setSuggestions([]);
    } finally {
      setSearching(false);
    }
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

