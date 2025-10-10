import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gamehub/localization/localized_text.dart';
import 'package:get_it/get_it.dart';
import '../../core/errors/api_error.dart';
import '../../localization/localization_service.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../models/participants/participants_request_model.dart';
import '../../models/user/user_response_model.dart';
import '../../services/game_post/game_post_service.dart';
import '../../services/participants/participants_service.dart';
import '../../services/user/user_service.dart';

class GamePostDetailsViewModel extends ChangeNotifier {
  final GamePostService _gamePostService;
  final ParticipantsService _participantsService;
  final UserService _userService;
  final GamePostResponseModel gamePost;
  final VoidCallback? onGameJoined;
  bool _isLoading = false;
  String? _error;
  bool _hasJoined = false;
  int _currentParticipantCount;
  UserResponseModel? _currentUser;

  GamePostDetailsViewModel({
    required this.gamePost,
    this.onGameJoined,
    GamePostService? gamePostService,
    ParticipantsService? participantsService,
    UserService? userService,
  }) : _gamePostService = gamePostService ?? GetIt.instance<GamePostService>(),
       _participantsService = participantsService ?? GetIt.instance<ParticipantsService>(),
       _userService = userService ?? GetIt.instance<UserService>(),
       _currentParticipantCount = gamePost.currentParticipantCount {
    _loadCurrentUser();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasJoined => _hasJoined;
  int get currentParticipantCount => _currentParticipantCount;
  bool get isGameFull => _currentParticipantCount >= gamePost.maxParticipants;
  bool get canJoinGame => !_hasJoined && !isGameFull && !_isLoading;
  bool get isHost => _currentUser?.id == gamePost.hostUserId;

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
      _currentParticipantCount++; // Increment local count immediately
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
      
      // Call the callback to refresh the parent screen
      onGameJoined?.call();
      
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
        } else if (apiError.code == 'E2302') {
          // Game is full error
          _error = 'game_post_details.game_full'.localized;
          // Show toast message for better user experience
          Fluttertoast.showToast(
            msg: 'game_post_details.game_full'.localized,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red[800],
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

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _userService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // If we can't load the current user, we'll just assume they're not the host
      // This could happen if the user is not authenticated or there's a network error
      _currentUser = null;
    }
  }
} 