import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/game_post/game_post_service.dart';
import '../../config/injection.dart';
import '../../core/utils/date_util.dart';

class MapContent extends StatefulWidget {
  @override
  _MapContentState createState() => _MapContentState();
}

class _MapContentState extends State<MapContent> {
  GoogleMapController? mapController;
  final GamePostService _gamePostService = getIt<GamePostService>();
  Set<Marker> _markers = {};
  LatLng? _initialPosition; // Changed to nullable to allow dynamic initialization

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
      final position = await _determinePosition();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
      await _fetchAndSetMarkers(position.latitude, position.longitude);
    } catch (error) {
      // Handle initialization errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing map: $error')),
      );
    }
  }

  Future<void> _fetchAndSetMarkers(double latitude, double longitude) async {
    try {
      const rangeInKm = 15.0;

      // Fetch game posts from backend
      final gamePosts = await _gamePostService.findAllNearby(latitude, longitude, rangeInKm);

      setState(() {
        _markers = gamePosts.map((gamePost) {
          return Marker(
            markerId: MarkerId(gamePost.postId.toString()),
            position: LatLng(gamePost.latitude, gamePost.longitude),
            infoWindow: InfoWindow(
              title: gamePost.location,
              snippet:
              '${gamePost.description}\nScheduled: ${DateUtil.formatScheduledDate(gamePost.scheduledDate)}\nMax Participants: ${gamePost.maxParticipants}',
            ),
          );
        }).toSet();
      });
    } catch (error) {
      // Handle errors, e.g., show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching game posts: $error')),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
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
        tooltip: 'Refresh nearby games',
        child: Icon(Icons.refresh),
      ),
    );
  }
}