import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../services/game_post/game_post_service.dart';

class GamePostDetailsViewModel extends ChangeNotifier {
  final GamePostService _gamePostService;
  final GamePostResponseModel gamePost;
  bool _isLoading = false;
  String? _error;

  GamePostDetailsViewModel({
    required this.gamePost,
    GamePostService? gamePostService,
  }) : _gamePostService = gamePostService ?? GetIt.instance<GamePostService>();

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> joinGame() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implement join game functionality
      // await _gamePostService.joinGame(gamePost.postId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
} 