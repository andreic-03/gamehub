import 'package:dio/dio.dart';
import 'package:gamehub/models/user/user_registration_request_model.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import '../../models/user/user_response_model.dart';

part 'user_service.g.dart';

@RestApi()
@injectable
abstract class UserService {
  @factoryMethod
  factory UserService(Dio dio, {@Named("baseURL") String baseUrl}) = _UserService;
  
  @POST("/user/registration")
  Future<UserResponseModel> register(@Body() UserRegistrationRequestModel requestModel);
  
  @GET("/user/info")
  Future<UserResponseModel> getCurrentUser();
}