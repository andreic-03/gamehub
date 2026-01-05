import 'package:flutter/material.dart';
import 'package:gamehub/localization/localized_text.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../services/game_post/game_post_service.dart';
import '../../config/injection.dart';
import '../../core/utils/date_util.dart';
import '../../core/utils/location_cache.dart';
import '../../localization/localization_service.dart';
import '../game_post/game_post_details_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final GamePostService _gamePostService = getIt<GamePostService>();
  Set<Marker> _markers = {};
  List<GamePostResponseModel> _gamePosts = [];
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _initializeMap() async {
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
      
      if (mounted) {
        setState(() {
          _initialPosition = LatLng(latitude, longitude);
        });
      }
      await _fetchAndSetMarkers(latitude, longitude);
    } catch (error) {
      // Handle initialization errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'error.error_initializing_map'.localized}: $error')),
        );
      }
    }
  }

  Future<void> _fetchAndSetMarkers(double latitude, double longitude) async {
    try {
      final rangeInKm = LocationCache.hasSearchRange
          ? LocationCache.cachedSearchRangeInKm!
          : 15.0;

      // Fetch game posts from backend
      _gamePosts = await _gamePostService.findAllNearby(latitude, longitude, rangeInKm);

      if (mounted) {
        setState(() {
          _markers = _gamePosts.map((gamePost) {
            return Marker(
              markerId: MarkerId(gamePost.postId.toString()),
              position: LatLng(gamePost.latitude, gamePost.longitude),
              onTap: () => _showGamePostBottomSheet(gamePost),
            );
          }).toSet();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'error.error_fetching_games'.localized}: $error')),
        );
      }
    }
  }

  void _showGamePostBottomSheet(GamePostResponseModel gamePost) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Game name
              Text(
                gamePost.gameName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Location
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gamePost.location,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Scheduled date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateUtil.formatScheduledDate(gamePost.scheduledDate),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Host
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    gamePost.hostName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Participants
              Row(
                children: [
                  Icon(Icons.group, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${gamePost.currentParticipantCount}/${gamePost.maxParticipants} ${'game_post_details.participants'.localized}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // View details button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GamePostDetailsScreen(
                          gamePost: gamePost,
                          onGameJoined: () {
                            // Refresh markers when user joins a game
                            if (_initialPosition != null) {
                              _fetchAndSetMarkers(
                                _initialPosition!.latitude,
                                _initialPosition!.longitude,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('game_post_details.title'.localized),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('error.location_services_disabled'.localized);
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('error.location_permissions_denied'.localized);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('error.location_permissions_permanently_denied'.localized);
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialPosition == null
          ? Center(child: CircularProgressIndicator()) // Show loader until position is initialized
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition!,
          zoom: 11.0,
        ),
        markers: _markers,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_initialPosition != null) {
            await _fetchAndSetMarkers(_initialPosition!.latitude, _initialPosition!.longitude);
          }
        },
        tooltip: 'map.refresh_tooltip'.localized,
        child: Icon(Icons.refresh),
      ),
    );
  }
}