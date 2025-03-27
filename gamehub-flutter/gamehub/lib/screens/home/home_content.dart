import 'package:flutter/material.dart';
import 'package:gamehub/models/game_post/game_post_response_model.dart';
import '../../config/injection.dart';
import '../../core/viewmodels/home_view_model.dart';
import '../game_post/game_post_details_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<HomeViewModel>();
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.fetchGamePosts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${_viewModel.errorMessage}'),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_viewModel.gamePosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No game posts found nearby.'),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Refresh'),
            ),
            Slider(
              value: _viewModel.searchRangeInKm,
              min: 1.0,
              max: 50.0,
              divisions: 49,
              label: '${_viewModel.searchRangeInKm.round()} km',
              onChanged: (double value) async {
                await _viewModel.setSearchRange(value);
                setState(() {});
              },
            ),
            Text('Search Range: ${_viewModel.searchRangeInKm.round()} km'),
          ],
        ),
      );
    } else {
      final gamePosts = _viewModel.gamePosts;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _viewModel.searchRangeInKm,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    label: '${_viewModel.searchRangeInKm.round()} km',
                    onChanged: (double value) async {
                      await _viewModel.setSearchRange(value);
                      setState(() {});
                    },
                  ),
                ),
                Text('${_viewModel.searchRangeInKm.round()} km'),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadData,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePostDetailsScreen(
                            gamePost: gamePost,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }
}