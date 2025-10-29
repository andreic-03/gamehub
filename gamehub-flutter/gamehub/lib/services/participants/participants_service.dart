import 'package:dio/dio.dart';
import 'package:gamehub/models/participants/participants_request_model.dart';
import 'package:gamehub/models/participants/participants_response_model.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'participants_service.g.dart';

@RestApi()
@injectable
abstract class ParticipantsService {
  @factoryMethod
  factory ParticipantsService(Dio dio, {@Named("baseURL") String baseUrl}) = _ParticipantsService;

  @POST("/participants")
  Future<ParticipantsResponseModel> createParticipant(@Body() ParticipantsRequestModel request);

  @GET("/participants/is-joined")
  Future<bool> isJoined(@Query("gamePostId") int gamePostId);
}
