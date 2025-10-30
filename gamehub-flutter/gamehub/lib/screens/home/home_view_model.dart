import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../../models/game_post/game_post_response_model.dart';
import '../../../services/game_post/game_post_service.dart';
import '../../core/viewmodels/base_view_model.dart';
import '../../core/utils/location_cache.dart';

/// ViewModel that handles home screen business logic
@injectable
class HomeViewModel extends BaseViewModel {
  final GamePostService _gamePostService;
  List<GamePostResponseModel> _gamePosts = [];
  double _searchRangeInKm = 15.0;

  /// Constructor that injects the game post service
  HomeViewModel(this._gamePostService);

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
        double latitude;
        double longitude;
        
        // Try to use cached location first
        if (LocationCache.hasLocation) {
          latitude = LocationCache.cachedLatitude!;
          longitude = LocationCache.cachedLongitude!;
        } else {
          // If no cached location, fetch it
          final position = await _determinePosition();
          latitude = position.latitude;
          longitude = position.longitude;
          
          // Cache it for future use
          LocationCache.setPosition(position);
        }
        
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

  /// Determines the user's current position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When permissions are granted, get the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}