import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/auth/auth_service.dart';
import '../../services/user/user_service.dart';
import '../../models/auth/auth_request_model.dart';
import '../../models/error/error_response.dart';
import '../errors/api_error.dart';
import 'base_view_model.dart';
import '../utils/user_cache.dart';
import '../utils/location_cache.dart';

/// ViewModel that handles authentication-related business logic
@injectable
class AuthViewModel extends BaseViewModel {
  final AuthService _authService;
  final UserService _userService;
  String? _token;

  /// Constructor that injects the auth service
  AuthViewModel(this._authService, this._userService);

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
    // Clear cached user data
    UserCache.clear();
    // Clear cached location data
    LocationCache.clear();
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
        
        // Load and cache user data immediately after successful login
        try {
          final user = await _userService.getCurrentUser();
          UserCache.setUser(user);
        } catch (e) {
          // If we can't load user data, continue anyway - it will be loaded later
          // This prevents login from failing if there's an issue with the user endpoint
        }
        
        // Cache user location immediately after successful login
        try {
          await _cacheUserLocation();
        } catch (e) {
          // If we can't get location, continue anyway - location can be fetched later
          // This prevents login from failing if there's an issue with location permissions
        }
        
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
  
  /// Caches the user's current location
  Future<void> _cacheUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When permissions are granted, get the current position and cache it
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LocationCache.setPosition(position);
  }
  
  // TODO: Add these methods when the AuthService supports them
  // - register(username, email, password)
  // - validateToken()
} 