import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/api_error.dart';
import '../../services/user/user_service.dart';
import '../../models/user/user_registration_request_model.dart';
import '../../models/user/user_response_model.dart';
import '../../models/error/error_response.dart';
import '../../core/viewmodels/base_view_model.dart';

/// ViewModel that handles user registration business logic
@injectable
class RegistrationViewModel extends BaseViewModel {
  final UserService _userService;

  /// Constructor that injects the user service
  RegistrationViewModel(this._userService);

  /// Registers a new user with the provided information
  Future<UserResponseModel?> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await runBusyFuture(() async {
      try {
        final registrationRequest = UserRegistrationRequestModel(
          username: username,
          email: email,
          password: password,
          fullName: fullName,
        );

        final userResponse = await _userService.register(registrationRequest);
        return userResponse;
      } on DioException catch (e) {
        if (e.response != null && e.response!.data != null) {
          try {
            final errorResponse = ErrorResponse.fromJson(e.response!.data);
            final errorMessage = errorResponse.details.isNotEmpty 
                ? errorResponse.details.join('\n') 
                : errorResponse.message;
            throw errorMessage;
          } catch (parseError) {
            // If we can't parse the error response, try to use the ApiError
            final apiError = ApiError.fromDioError(e);
            throw apiError.userFriendlyMessage;
          }
        } else {
          throw 'Connection error. Please check your internet connection and try again.';
        }
      } catch (e) {
        if (e is String) {
          throw e;
        }
        throw 'An unexpected error occurred during registration. Please try again.';
      }
    });
  }

  /// Validates the username field
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validates the email field
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates the password field
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (value.length > 50) {
      return 'Password must be less than 50 characters';
    }
    return null;
  }

  /// Validates the confirm password field
  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates the full name field
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters long';
    }
    if (value.length > 50) {
      return 'Full name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Full name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates all form fields
  bool validateForm({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
  }) {
    final usernameError = validateUsername(username);
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);
    final confirmPasswordError = validateConfirmPassword(confirmPassword, password);
    final fullNameError = validateFullName(fullName);

    return usernameError == null &&
           emailError == null &&
           passwordError == null &&
           confirmPasswordError == null &&
           fullNameError == null;
  }
}
