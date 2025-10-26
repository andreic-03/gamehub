import 'package:injectable/injectable.dart';

import '../../models/game_post/game_post_response_model.dart';
import '../../services/game_post/game_post_service.dart';
import '../../core/viewmodels/base_view_model.dart';

/// ViewModel that handles my game posts screen business logic
@injectable
class MyGamePostsViewModel extends BaseViewModel {
  final GamePostService _gamePostService;
  List<GamePostResponseModel> _gamePosts = [];

  /// Constructor that injects the game post service
  MyGamePostsViewModel(this._gamePostService);

  /// Returns the current list of game posts
  List<GamePostResponseModel> get gamePosts => _gamePosts;

  /// Fetches game posts from the service for the logged-in user
  Future<void> fetchMyGamePosts() async {
    await runBusyFuture(() async {
      try {
        _gamePosts = await _gamePostService.findMyGamePosts();
        return _gamePosts;
      } catch (e) {
        setError(e.toString());
        _gamePosts = [];
        return _gamePosts;
      }
    });
  }
}
