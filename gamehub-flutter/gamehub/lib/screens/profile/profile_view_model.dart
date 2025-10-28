import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/utils/user_cache.dart';
import '../../core/viewmodels/base_view_model.dart';
import '../../services/user/user_service.dart';
import '../../models/error/error_response.dart';
import '../../models/user/user_response_model.dart';

@injectable
class ProfileViewModel extends BaseViewModel {
  final UserService _userService;

  ProfileViewModel(this._userService);

  Future<UserResponseModel?> getCurrentUser() async {
    // First check if we have a cached user
    if (UserCache.cachedUser != null) {
      return UserCache.cachedUser;
    }

    return await runBusyFuture(() async {
      try {
        final user = await _userService.getCurrentUser();
        // Cache the user for future use
        UserCache.setUser(user);
        return user;
      } on DioException catch (e) {
        if (e.response != null && e.response!.data != null) {
          final errorResponse = ErrorResponse.fromJson(e.response!.data);
          throw errorResponse.message ?? 'An error occurred. Please try again.';
        } else {
          throw 'An error occurred. Please try again.';
        }
      } catch (e) {
        throw 'An unexpected error occurred. Please try again.';
      }
    });
  }
}
