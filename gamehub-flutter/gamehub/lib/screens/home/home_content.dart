import 'package:flutter/material.dart';
import 'package:gamehub/models/game_post/game_post_response_model.dart';
import '../../config/injection.dart';
import '../../core/viewmodels/home_view_model.dart';
import '../../core/utils/date_util.dart';
import '../game_post/game_post_details_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<HomeViewModel>();
    _loadData();
  }

  // Method to refresh data that can be called externally
  Future<void> refreshData() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.fetchGamePosts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Loading nearby games...'),
          ],
        ),
      );
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
            Text('No games found nearby.'),
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
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Slider(
          //           value: _viewModel.searchRangeInKm,
          //           min: 1.0,
          //           max: 50.0,
          //           divisions: 49,
          //           label: '${_viewModel.searchRangeInKm.round()} km',
          //           onChanged: (double value) async {
          //             await _viewModel.setSearchRange(value);
          //             setState(() {});
          //           },
          //         ),
          //       ),
          //       Text('${_viewModel.searchRangeInKm.round()} km'),
          //       IconButton(
          //         icon: Icon(Icons.refresh),
          //         onPressed: _loadData,
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: gamePosts.length,
              itemBuilder: (context, index) {
                final gamePost = gamePosts[index];
                return GestureDetector(
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
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(gamePost.gamePictureUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Semi-transparent overlay for text readability
                        Container(
                          color: Colors.black.withOpacity(0.4),
                        ),
                        Positioned(
                          left: 30,
                          bottom: 24,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gamePost.location,
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Game: ${gamePost.gameName}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Scheduled: ${DateUtil.formatScheduledDate(gamePost.scheduledDate)}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Participants: ${gamePost.maxParticipants}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Host name: ${gamePost.hostName}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Simple page indicator (bottom-right)
                        // Positioned(
                        //   right: 12,
                        //   bottom: 12,
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white24,
                        //       borderRadius: BorderRadius.circular(16),
                        //     ),
                        //     child: Text(
                        //       '${index + 1}/${gamePosts.length}',
                        //       style: const TextStyle(color: Colors.white),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
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