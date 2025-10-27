import 'package:injectable/injectable.dart';

import '../../../models/game_post/game_post_response_model.dart';
import '../../../services/game_post/game_post_service.dart';
import '../../../services/location/location_service.dart';
import 'base_view_model.dart';

/// ViewModel that handles home screen business logic
@injectable
class HomeViewModel extends BaseViewModel {
  final GamePostService _gamePostService;
  final LocationService _locationService;
  List<GamePostResponseModel> _gamePosts = [];
  double _searchRangeInKm = 15.0;

  /// Constructor that injects the game post service and location service
  HomeViewModel(this._gamePostService, this._locationService);

  /// Returns the current list of game posts
  List<GamePostResponseModel> get gamePosts => _gamePosts;

  /// Returns the current search range in kilometers
  double get searchRangeInKm => _searchRangeInKm;

  /// Sets the search range in kilometers and refreshes data
  Future<void> setSearchRange(double rangeInKm) async {
    _searchRangeInKm = rangeInKm;
    await fetchGamePosts();
  }

  /// Fetches game posts from the service based on the user's location
  Future<void> fetchGamePosts() async {
    await runBusyFuture(() async {
      try {
        final position = await _locationService.getCurrentPosition();
        final latitude = position.latitude;
        final longitude = position.longitude;

        _gamePosts = await _gamePostService.findAllNearby(
          latitude, 
          longitude, 
          _searchRangeInKm
        );

        return _gamePosts;
      } catch (e) {
        setError(e.toString());
        _gamePosts = [];
        return _gamePosts;
      }
    });
  }
}