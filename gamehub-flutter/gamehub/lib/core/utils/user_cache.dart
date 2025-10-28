import '../../models/user/user_response_model.dart';

/// Global cache for current user data to avoid repeated API calls
class UserCache {
  static int? _cachedUserId;
  static UserResponseModel? _cachedUser;

  /// Get the cached user ID
  static int? get cachedUserId => _cachedUserId;

  /// Get the cached user
  static UserResponseModel? get cachedUser => _cachedUser;

  /// Set the cached user
  static void setUser(UserResponseModel? user) {
    _cachedUser = user;
    _cachedUserId = user?.id;
  }

  /// Set the cached user ID
  static void setUserId(int? userId) {
    _cachedUserId = userId;
  }

  /// Clear the cached user data
  static void clear() {
    _cachedUserId = null;
    _cachedUser = null;
  }
}
