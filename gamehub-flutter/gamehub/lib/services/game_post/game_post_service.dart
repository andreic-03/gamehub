import 'package:dio/dio.dart';
import 'package:gamehub/models/game_post/game_post_request_model.dart';
import 'package:gamehub/models/game_post/game_post_response_model.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'game_post_service.g.dart';

@RestApi()
@injectable
abstract class GamePostService {
  @factoryMethod
  factory GamePostService(Dio dio, {@Named("baseURL") String baseUrl}) = _GamePostService;

  @GET("/game-posts/nearby")
  Future<List<GamePostResponseModel>> findAllNearby(
      @Query("latitude") double latitude,
      @Query("longitude") double longitude,
      @Query("rangeInKm") double rangeInKm,
      );

  @POST("/game-posts")
  Future<GamePostResponseModel> createGamePost(@Body() GamePostRequestModel request);

  @PUT("/game-posts/{id}")
  Future<GamePostResponseModel> updateGamePost(@Path("id") int id, @Body() GamePostRequestModel request);
}