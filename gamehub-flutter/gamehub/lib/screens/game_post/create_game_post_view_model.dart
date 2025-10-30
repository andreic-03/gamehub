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

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay time) {
    _selectedTime = time;
    notifyListeners();
  }

  DateTime get scheduledDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

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

      // Validate form fields (location, participants, date-time)
      if (!isFormValid(
        location: locationController.text,
        maxParticipants: maxParticipantsController.text,
      )) {
        setError('registration.please_fix_errors'.localized);
        CustomToast.showText(
          context,
          'registration.please_fix_errors'.localized,
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

  /// Validates that scheduled date-time is at least current time + 2 hours
  String? validateDateTime(DateTime scheduledDateTime) {
    final DateTime minAllowed = DateTime.now().add(const Duration(hours: 2));
    if (scheduledDateTime.isBefore(minAllowed)) {
      return 'create_game_post.date_must_be_future'.localized;
    }
    return null;
  }

  String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'create_game_post.please_enter_location'.localized;
    }
    return null;
  }

  String? validateMaxParticipants(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'create_game_post.max_participants_required'.localized;
    }
    final max = int.tryParse(value);
    if (max == null) {
      return 'create_game_post.please_enter_valid_number'.localized;
    }
    if (max < 2) {
      return 'create_game_post.min_participants_two'.localized;
    }
    if (max > 100) {
      return 'create_game_post.max_participants_limit'.localized;
    }
    return null;
  }

  bool isFormValid({
    required String location,
    required String maxParticipants,
  }) {
    return validateLocation(location) == null &&
        validateMaxParticipants(maxParticipants) == null &&
        validateDateTime(scheduledDateTime) == null;
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

