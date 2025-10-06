import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import '../../models/auth/auth_request_model.dart';
import '../../models/auth/auth_response_model.dart';

part 'auth_service.g.dart';

@RestApi()
@injectable
abstract class AuthService {
  @factoryMethod
  factory AuthService(Dio dio, {@Named("baseURL") String baseUrl}) = _AuthService;

  @POST("/auth/login")
  Future<AuthResponseModel> login(@Body() AuthRequestModel requestModel);

  @POST("/auth/logout")
  Future<void> logout();
}
