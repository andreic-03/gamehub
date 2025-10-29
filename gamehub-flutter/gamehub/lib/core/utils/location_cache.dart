import 'package:geolocator/geolocator.dart';

/// Global cache for user location data to avoid repeated API calls
class LocationCache {
  static double? _cachedLatitude;
  static double? _cachedLongitude;
  static Position? _cachedPosition;

  /// Get the cached latitude
  static double? get cachedLatitude => _cachedLatitude;

  /// Get the cached longitude
  static double? get cachedLongitude => _cachedLongitude;

  /// Get the cached position
  static Position? get cachedPosition => _cachedPosition;

  /// Set the cached location
  static void setLocation(double latitude, double longitude, Position? position) {
    _cachedLatitude = latitude;
    _cachedLongitude = longitude;
    _cachedPosition = position;
  }

  /// Set the cached position (also extracts lat/lng)
  static void setPosition(Position position) {
    _cachedPosition = position;
    _cachedLatitude = position.latitude;
    _cachedLongitude = position.longitude;
  }

  /// Check if location is cached
  static bool get hasLocation => _cachedLatitude != null && _cachedLongitude != null;

  /// Clear the cached location data
  static void clear() {
    _cachedLatitude = null;
    _cachedLongitude = null;
    _cachedPosition = null;
  }
}

