import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../services/auth/auth_service.dart';
import '../../../models/auth/auth_request_model.dart';
import '../../../models/error/error_response.dart';
import '../errors/api_error.dart';
import 'base_view_model.dart';

/// ViewModel that handles authentication-related business logic
@injectable
class AuthViewModel extends BaseViewModel {
  final AuthService _authService;
  String? _token;

  /// Constructor that injects the auth service
  AuthViewModel(this._authService);

  /// Returns the current auth token
  String? get token => _token;

  /// Returns whether the user is authenticated
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Sets the authentication token and notifies listeners
  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  /// Clears the authentication token and notifies listeners
  void clearToken() {
    _token = null;
    notifyListeners();
  }

  /// Logs in a user with username and password
  Future<bool> login(String username, String password) async {
    return await runBusyFuture(() async {
      try {
        final authRequest = AuthRequestModel(
          identifier: username,
          password: password,
        );

        final authResponse = await _authService.login(authRequest);
        
        setToken(authResponse.accessToken);
        return true;
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
        throw 'An unexpected error occurred. Please try again.';
      }
    }) ?? false;
  }

  /// Logs out the current user
  Future<bool> logout() async {
    return await runBusyFuture(() async {
      try {
        final result = await _authService.logout();
        clearToken();
        return true;
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
        throw 'An unexpected error occurred during logout. Please try again.';
      }
    }) ?? false;
  }
  
  // TODO: Add these methods when the AuthService supports them
  // - register(username, email, password)
  // - validateToken()
} 