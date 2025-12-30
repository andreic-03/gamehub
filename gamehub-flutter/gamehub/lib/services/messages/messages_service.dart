import 'package:dio/dio.dart';
import 'package:gamehub/models/message/message_model.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'messages_service.g.dart';

@RestApi()
@injectable
abstract class MessagesService {
  @factoryMethod
  factory MessagesService(Dio dio, {@Named("baseURL") String baseUrl}) = _MessagesService;

  @GET("/messages/game-post/{gamePostId}")
  Future<List<MessageModel>> getMessagesByGamePostId(@Path("gamePostId") int gamePostId);
}

