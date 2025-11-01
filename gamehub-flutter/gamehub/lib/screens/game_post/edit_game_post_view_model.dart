import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/errors/api_error.dart';
import '../../localization/localized_text.dart';
import '../../models/game/games_response_model.dart';
import '../../models/game_post/game_post_request_model.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../services/game/game_service.dart';
import '../../services/game_post/game_post_service.dart';
import '../../widgets/custom_toast.dart';

/// Unified ViewModel for both creating and updating a Game Post.
/// Use with create when originalGamePost is null. Use with update when provided.
class EditGamePostViewModel extends ChangeNotifier {
  final GamePostService _gamePostService = GetIt.instance<GamePostService>();
  final GameService _gameService = GetIt.instance<GameService>();

  final GamePostResponseModel? originalGamePost;

  // Shared controllers
  final TextEditingController locationController = TextEditingController();
  final TextEditingController maxParticipantsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Create-mode only controllers
  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController gameIdController = TextEditingController();

  // Coordinates (store as doubles for both modes)
  double? latitude;
  double? longitude;

  // Date/time
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  EditGamePostViewModel({required this.originalGamePost}) {
    _initialize();
  }

  void _initialize() {
    if (originalGamePost != null) {
      // Seed with existing data for update mode
      final gp = originalGamePost!;
      locationController.text = gp.location;
      maxParticipantsController.text = gp.maxParticipants.toString();
      descriptionController.text = gp.description ?? '';
      latitude = gp.latitude;
      longitude = gp.longitude;
      try {
        final dt = DateTime.parse(gp.scheduledDate);
        _selectedDate = dt;
        _selectedTime = TimeOfDay.fromDateTime(dt);
      } catch (_) {}
    }
  }

  // Accessors
  DateTime get selectedDate => _selectedDate;
  TimeOfDay get selectedTime => _selectedTime;
  DateTime get scheduledDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  void setCoordinates(double lat, double lng, String? address) {
    latitude = lat;
    longitude = lng;
    if (address != null && address.isNotEmpty) {
      locationController.text = address;
    }
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      _selectedTime = picked;
      notifyListeners();
    }
  }

  // Validation (use localized strings from create/update)
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
    if (originalGamePost != null && max < originalGamePost!.currentParticipantCount) {
      return 'create_game_post.cannot_be_less_than_current'.localized
          .replaceAll('{count}', originalGamePost!.currentParticipantCount.toString());
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'create_game_post.description_max_500'.localized;
    }
    return null;
  }

  String? validateDateTime() {
    final minAllowed = DateTime.now().add(const Duration(hours: 2));
    if (scheduledDateTime.isBefore(minAllowed)) {
      return 'create_game_post.date_must_be_future'.localized;
    }
    return null;
  }

  // Game search (create mode)
  Timer? _searchDebounce;
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
      List<GamesResponseModel> results = [];
      try {
        results = await _gameService.getGameByName('');
      } catch (_) {}
      setSuggestions(results);
    } finally {
      setSearching(false);
    }
  }

  void selectGame(
    GamesResponseModel game, {
    required void Function(List<GamesResponseModel>) setSuggestions,
  }) {
    gameNameController.text = game.gameName;
    gameIdController.text = game.gameId.toString();
    setSuggestions([]);
    notifyListeners();
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get isFormValid {
    return validateLocation(locationController.text) == null &&
        validateMaxParticipants(maxParticipantsController.text) == null &&
        validateDescription(descriptionController.text) == null &&
        validateDateTime() == null &&
        hasCoordinates;
  }

  Future<GamePostResponseModel?> submit({required BuildContext context}) async {
    if (!isFormValid) {
      CustomToast.showText(context, 'registration.please_fix_errors'.localized, backgroundColor: Colors.red);
      return null;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final request = GamePostRequestModel(
        gameId: originalGamePost?.gameId ?? int.parse(gameIdController.text),
        location: locationController.text.trim(),
        latitude: latitude!,
        longitude: longitude!,
        scheduledDate: scheduledDateTime,
        maxParticipants: int.parse(maxParticipantsController.text.trim()),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      );

      GamePostResponseModel? result;
      if (originalGamePost == null) {
        await _gamePostService.createGamePost(request);
      } else {
        result = await _gamePostService.updateGamePost(originalGamePost!.postId, request);
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      String message;
      if (e is DioException) {
        final apiError = ApiError.fromDioError(e);
        message = apiError.message;
      } else if (e is ApiError) {
        message = e.message;
      } else {
        message = '${'create_game_post.error_creating'.localized}: $e';
      }
      CustomToast.showText(context, message, backgroundColor: Colors.red);
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    locationController.dispose();
    maxParticipantsController.dispose();
    descriptionController.dispose();
    gameNameController.dispose();
    gameIdController.dispose();
    super.dispose();
  }
}


