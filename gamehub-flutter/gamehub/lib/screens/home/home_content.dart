import 'package:flutter/material.dart';
import 'package:gamehub/models/game_post/game_post_response_model.dart';
import 'package:geolocator/geolocator.dart';

import '../../config/injection.dart';
import '../../services/game_post/game_post_service.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<GamePostResponseModel>> _futureGamePosts;
  final GamePostService _gamePostService = getIt<GamePostService>();

  @override
  void initState() {
    super.initState();
    _futureGamePosts = _fetchGamePosts();
  }

  Future<List<GamePostResponseModel>> _fetchGamePosts() async {
    final position = await _determinePosition();
    final latitude = position.latitude;
    final longitude = position.longitude;
    //TODO To change or make it editable
    const rangeInKm = 15.0;

    return await _gamePostService.findAllNearby(latitude, longitude, rangeInKm);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check for location permissions.
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

    // When permissions are granted, get the current position.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GamePostResponseModel>>(
      future: _futureGamePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No game posts found nearby.'));
        } else {
          final gamePosts = snapshot.data!;
          return ListView.builder(
            itemCount: gamePosts.length,
            itemBuilder: (context, index) {
              final gamePost = gamePosts[index];
              return Card(
                child: ListTile(
                  title: Text('Location: ${gamePost.location}'),
                  subtitle: Text(
                      'Scheduled: ${gamePost.scheduledDate}\nMax Participants: ${gamePost.maxParticipants}'),
                  trailing: Text('Host: ${gamePost.hostUserId}'),
                  onTap: () {
                    // Handle tap, possibly navigate to details
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}