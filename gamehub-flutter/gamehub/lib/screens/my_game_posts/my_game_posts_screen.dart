import 'package:flutter/material.dart';
import '../../config/injection.dart';
import '../../core/utils/date_util.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../game_post/game_post_details_screen.dart';
import 'my_game_posts_view_model.dart';

class MyGamePostsContent extends StatefulWidget {
  const MyGamePostsContent({Key? key}) : super(key: key);

  @override
  MyGamePostsContentState createState() => MyGamePostsContentState();
}

class MyGamePostsContentState extends State<MyGamePostsContent> {
  late final MyGamePostsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<MyGamePostsViewModel>();
    _loadData();
  }

  // Method to refresh data that can be called externally
  Future<void> refreshData() async {
    await _loadData();
  }

  // Method to check if there are game posts available
  bool get hasGamePosts => _viewModel.gamePosts.isNotEmpty;
  
  // Refresh content method for base screen integration
  Future<void> refreshContent() async {
    await refreshData();
  }

  Future<void> _loadData() async {
    await _viewModel.fetchMyGamePosts();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            LocalizedText('home.loading_games'),
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
              child: ListenableBuilder(
                listenable: LocalizationService.instance,
                builder: (context, child) {
                  return Text('home.retry'.localized);
                },
              ),
            ),
          ],
        ),
      );
    } else if (_viewModel.gamePosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LocalizedText('home.no_games'),
            SizedBox(height: 16),
            LocalizedText('home.refresh'),
          ],
        ),
      );
    } else {
      return _buildGamePostsList();
    }
  }

  Widget _buildGamePostsList() {
    final gamePosts = _viewModel.gamePosts;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 120.0, 16.0, 16.0),
      itemCount: gamePosts.length,
      itemBuilder: (context, index) {
        final gamePost = gamePosts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GamePostDetailsScreen(
                    gamePost: gamePost,
                    onGameJoined: refreshData,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Game image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          gamePost.gamePictureUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.sports_esports),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // Game info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gamePost.gameName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gamePost.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Date and participants
                  ListenableBuilder(
                    listenable: LocalizationService.instance,
                    builder: (context, child) {
                      return Text(
                        '${'game_post.scheduled'.localized}: ${DateUtil.formatScheduledDate(gamePost.scheduledDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  ListenableBuilder(
                    listenable: LocalizationService.instance,
                    builder: (context, child) {
                      final isFull =
                          gamePost.currentParticipantCount >=
                              gamePost.maxParticipants;
                      return Row(
                        children: [
                          Icon(
                            isFull ? Icons.person_off : Icons.people,
                            color: isFull ? Colors.red : Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${'game_post.participants'.localized}: ${gamePost.currentParticipantCount}/${gamePost.maxParticipants}',
                            style: TextStyle(
                              color: isFull ? Colors.red : Colors.grey[600],
                              fontSize: 14,
                              fontWeight: isFull ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
