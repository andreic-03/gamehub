import 'package:dio/dio.dart';
import 'package:gamehub/models/game/games_response_model.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'game_service.g.dart';

@RestApi()
@injectable
abstract class GameService {
  @factoryMethod
  factory GameService(Dio dio, {@Named("baseURL") String baseUrl}) = _GameService;

  @GET("/games/search")
  Future<List<GamesResponseModel>> getGameByName(@Query("name") String gameName);
}
