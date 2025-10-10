import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gamehub/localization/localized_text.dart';
import 'package:get_it/get_it.dart';
import '../../core/errors/api_error.dart';
import '../../localization/localization_service.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../models/participants/participants_request_model.dart';
import '../../services/game_post/game_post_service.dart';
import '../../services/participants/participants_service.dart';

class GamePostDetailsViewModel extends ChangeNotifier {
  final GamePostService _gamePostService;
  final ParticipantsService _participantsService;
  final GamePostResponseModel gamePost;
  bool _isLoading = false;
  String? _error;
  bool _hasJoined = false;

  GamePostDetailsViewModel({
    required this.gamePost,
    GamePostService? gamePostService,
    ParticipantsService? participantsService,
  }) : _gamePostService = gamePostService ?? GetIt.instance<GamePostService>(),
       _participantsService = participantsService ?? GetIt.instance<ParticipantsService>();

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasJoined => _hasJoined;

  Future<void> joinGame() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create participants request
      final participantsRequest = ParticipantsRequestModel(
        gamePostId: gamePost.postId,
        status: ParticipantsStatus.joined,
        isHost: false, // User joining is not the host
      );

      // Call the participants service
      final participantsResponse = await _participantsService.createParticipant(participantsRequest);
      
      // Update state to reflect successful join
      _hasJoined = true;
      _isLoading = false;
      notifyListeners();
      
      // Show success toast message
      Fluttertoast.showToast(
        msg: 'game_post_details.joined'.localized,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
      );
      
    } catch (e) {
      _isLoading = false;
      
      // Handle specific API errors
      if (e is DioException) {
        final apiError = ApiError.fromDioError(e);
        
        // Check if it's the specific "already participating" error
        if (apiError.code == 'E2301') {
          _error = 'game_post_details.already_joined'.localized;
          // Show toast message for better user experience
          Fluttertoast.showToast(
            msg: 'game_post_details.already_joined'.localized,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.orange[800],
            textColor: Colors.white,
          );
        } else {
          _error = apiError.userFriendlyMessage;
        }
      } else {
        _error = e.toString();
      }
      
      notifyListeners();
    }
  }
} 