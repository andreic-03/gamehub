import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/errors/api_error.dart';
import '../../widgets/custom_toast.dart';
import '../../localization/localized_text.dart';
import '../../models/game_post/game_post_request_model.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../services/game_post/game_post_service.dart';

class UpdateGamePostViewModel extends ChangeNotifier {
  final GamePostService _gamePostService;
  final GamePostResponseModel originalGamePost;
  
  // Form fields
  final TextEditingController locationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController maxParticipantsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  bool _isLoading = false;
  String? _error;
  Object? _lastException;
  
  UpdateGamePostViewModel({
    required this.originalGamePost,
    GamePostService? gamePostService,
  }) : _gamePostService = gamePostService ?? GetIt.instance<GamePostService>() {
    _initializeForm();
  }
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Object? get lastException => _lastException;
  DateTime get selectedDate => _selectedDate;
  TimeOfDay get selectedTime => _selectedTime;
  
  void _initializeForm() {
    // Initialize form fields with current game post data
    locationController.text = originalGamePost.location;
    latitudeController.text = originalGamePost.latitude.toString();
    longitudeController.text = originalGamePost.longitude.toString();
    maxParticipantsController.text = originalGamePost.maxParticipants.toString();
    descriptionController.text = originalGamePost.description ?? '';
    
    // Parse the scheduled date from the response model
    try {
      final dateTime = DateTime.parse(originalGamePost.scheduledDate);
      _selectedDate = dateTime;
      _selectedTime = TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      // If parsing fails, use current date/time
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
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
  
  String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'create_game_post.location_required'.localized;
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
    if (max < originalGamePost.currentParticipantCount) {
      return 'create_game_post.cannot_be_less_than_current'.localized
          .replaceAll('{count}', originalGamePost.currentParticipantCount.toString());
    }
    return null;
  }
  
  String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'create_game_post.description_max_500'.localized;
    }
    return null;
  }
  
  bool get isFormValid {
    return validateLocation(locationController.text) == null &&
            validateMaxParticipants(maxParticipantsController.text) == null &&
            validateDescription(descriptionController.text) == null &&
            validateDateTime() == null;
  }
  
  DateTime get scheduledDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  /// Validates that scheduled date-time is at least current time + 2 hours
  String? validateDateTime() {
    final DateTime minAllowed = DateTime.now().add(const Duration(hours: 2));
    final DateTime selected = scheduledDateTime;
    if (selected.isBefore(minAllowed)) {
      return 'create_game_post.date_must_be_future'.localized;
    }
    return null;
  }
  
  Future<GamePostResponseModel?> updateGamePost({required BuildContext context}) async {
    if (!isFormValid) {
      _error = 'registration.please_fix_errors'.localized;
      notifyListeners();
      // Brief user-facing feedback
      CustomToast.showText(context, 'registration.please_fix_errors'.localized, backgroundColor: Colors.red);
      return null;
    }
    
    try {
      _isLoading = true;
      _error = null;
      _lastException = null;
      notifyListeners();
      
      final updateRequest = GamePostRequestModel(
        gameId: originalGamePost.gameId, // Keep the same game
        location: locationController.text.trim(),
        latitude: double.parse(latitudeController.text.trim()),
        longitude: double.parse(longitudeController.text.trim()),
        scheduledDate: scheduledDateTime,
        maxParticipants: int.parse(maxParticipantsController.text.trim()),
        description: descriptionController.text.trim().isEmpty 
            ? null 
            : descriptionController.text.trim(),
      );
      
      final updated = await _gamePostService.updateGamePost(originalGamePost.postId, updateRequest);
      
      _isLoading = false;
      notifyListeners();
      return updated;
      
    } catch (e) {
      _isLoading = false;
      _lastException = e;
      
      // Handle specific API errors
      String message;
      if (e is DioException) {
        final apiError = ApiError.fromDioError(e);
        _error = apiError.userFriendlyMessage;
        message = apiError.message;
      } else if (e is ApiError) {
        _error = e.userFriendlyMessage;
        message = e.message;
      } else {
        _error = e.toString();
        message = e.toString();
      }
      // Show toast with only the API message
      CustomToast.showText(context, message, backgroundColor: Colors.red);
      
      notifyListeners();
      return null;
    }
  }
  
  bool hasCoordinates() {
    final lat = double.tryParse(latitudeController.text);
    final lng = double.tryParse(longitudeController.text);
    return lat != null && lng != null;
  }

  void updateCoordinates(double latitude, double longitude, String? address) {
    latitudeController.text = latitude.toString();
    longitudeController.text = longitude.toString();
    if (address != null && address.isNotEmpty) {
      locationController.text = address;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    locationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    maxParticipantsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
