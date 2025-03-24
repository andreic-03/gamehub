import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/viewmodels/base_view_model.dart';
import '../../services/user/user_service.dart';
import '../../models/error/error_response.dart';
import '../../models/user/user_response_model.dart';

@injectable
class ProfileViewModel extends BaseViewModel {
  final UserService _userService;

  ProfileViewModel(this._userService);

  Future<UserResponseModel?> getCurrentUser() async {
    return await runBusyFuture(() async {
      try {
        return await _userService.getCurrentUser();
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
