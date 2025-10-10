import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/errors/api_error.dart';
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
  
  UpdateGamePostViewModel({
    required this.originalGamePost,
    GamePostService? gamePostService,
  }) : _gamePostService = gamePostService ?? GetIt.instance<GamePostService>() {
    _initializeForm();
  }
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
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
      return 'Location is required';
    }
    return null;
  }
  
  String? validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Latitude is required';
    }
    final lat = double.tryParse(value);
    if (lat == null) {
      return 'Please enter a valid latitude';
    }
    if (lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }
    return null;
  }
  
  String? validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Longitude is required';
    }
    final lng = double.tryParse(value);
    if (lng == null) {
      return 'Please enter a valid longitude';
    }
    if (lng < -180 || lng > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }
  
  String? validateMaxParticipants(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Max participants is required';
    }
    final max = int.tryParse(value);
    if (max == null) {
      return 'Please enter a valid number';
    }
    if (max < 2) {
      return 'Must have at least 2 participants';
    }
    if (max > 100) {
      return 'Maximum 100 participants allowed';
    }
    if (max < originalGamePost.currentParticipantCount) {
      return 'Cannot be less than current participants (${originalGamePost.currentParticipantCount})';
    }
    return null;
  }
  
  String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }
  
  bool get isFormValid {
    return validateLocation(locationController.text) == null &&
           validateLatitude(latitudeController.text) == null &&
           validateLongitude(longitudeController.text) == null &&
           validateMaxParticipants(maxParticipantsController.text) == null &&
           validateDescription(descriptionController.text) == null;
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
  
  Future<bool> updateGamePost() async {
    if (!isFormValid) {
      _error = 'Please fix all validation errors';
      notifyListeners();
      return false;
    }
    
    try {
      _isLoading = true;
      _error = null;
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
      
      await _gamePostService.updateGamePost(originalGamePost.postId, updateRequest);
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _isLoading = false;
      
      // Handle specific API errors
      if (e is DioException) {
        final apiError = ApiError.fromDioError(e);
        _error = apiError.userFriendlyMessage;
      } else {
        _error = e.toString();
      }
      
      notifyListeners();
      return false;
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
