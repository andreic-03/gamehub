import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gamehub/services/user/user_service.dart';
import 'package:injectable/injectable.dart';
import '../../models/error/error_response.dart';
import '../../models/user/user_response_model.dart';

@injectable
class ProfileViewModel extends ChangeNotifier {
  final UserService _userService;

  ProfileViewModel(this._userService);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<UserResponseModel?> getCurrentUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userResponse = await _userService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return userResponse;

    } on DioException catch (e) {
      _isLoading = false;
      if (e.response != null && e.response!.data != null) {
        final errorResponse = ErrorResponse.fromJson(e.response!.data);
        _errorMessage = errorResponse.message;
      } else {
        _errorMessage = 'An error occurred. Please try again.';
      }
      notifyListeners();
      return null;

    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return null;
    }
  }
}
