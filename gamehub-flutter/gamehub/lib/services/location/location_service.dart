import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Service that handles location management with caching
@lazySingleton
class LocationService {
  Position? _lastKnownPosition;
  DateTime? _lastPositionTimestamp;
  static const Duration _positionCacheValidity = Duration(minutes: 5);

  /// Gets the current position with caching
  /// Returns cached position if it's valid, otherwise fetches a new one
  Future<Position> getCurrentPosition({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _lastKnownPosition = null;
      _lastPositionTimestamp = null;
    }

    if (_lastKnownPosition != null && _lastPositionTimestamp != null) {
      final cacheAge = DateTime.now().difference(_lastPositionTimestamp!);
      if (cacheAge < _positionCacheValidity) {
        print('📍 [LocationService] Using cached position (age: ${cacheAge.inSeconds}s)');
        return _lastKnownPosition!;
      }
    }

    await _ensureLocationPermissions();

    print('📍 [LocationService] Getting last known position...');
    Position? lastKnownPosition = await Geolocator.getLastKnownPosition();

    if (lastKnownPosition != null) {
      final age = DateTime.now().difference(lastKnownPosition.timestamp);
      print('📍 [LocationService] Got last known position (age: ${age.inSeconds}s)');

      if (age < _positionCacheValidity) {
        _lastKnownPosition = lastKnownPosition;
        _lastPositionTimestamp = DateTime.now();
        return lastKnownPosition;
      }
    }

    print('📍 [LocationService] Getting fresh position with medium accuracy...');
    final freshPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );

    _lastKnownPosition = freshPosition;
    _lastPositionTimestamp = DateTime.now();

    return freshPosition;
  }

  /// Clears the cached position
  void clearCache() {
    _lastKnownPosition = null;
    _lastPositionTimestamp = null;
    print('📍 [LocationService] Cache cleared');
  }

  /// Gets the last cached position without fetching a new one
  Position? getCachedPosition() {
    if (_lastKnownPosition != null && _lastPositionTimestamp != null) {
      final cacheAge = DateTime.now().difference(_lastPositionTimestamp!);
      if (cacheAge < _positionCacheValidity) {
        return _lastKnownPosition;
      }
    }
    return null;
  }

  /// Checks if location services are enabled and permissions are granted
  Future<void> _ensureLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
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
  }
}
