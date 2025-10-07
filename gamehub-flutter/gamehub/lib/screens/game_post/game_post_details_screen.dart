import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/game_post/game_post_response_model.dart';
import 'game_post_details_view_model.dart';

class GamePostDetailsScreen extends StatefulWidget {
  final GamePostResponseModel gamePost;

  const GamePostDetailsScreen({
    Key? key,
    required this.gamePost,
  }) : super(key: key);

  @override
  State<GamePostDetailsScreen> createState() => _GamePostDetailsScreenState();
}

class _GamePostDetailsScreenState extends State<GamePostDetailsScreen> {
  late final GamePostDetailsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GamePostDetailsViewModel(gamePost: widget.gamePost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Post'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.gamePost.location,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Time Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.gamePost.scheduledDate,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Participants Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Participants',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Max ${widget.gamePost.maxParticipants} participants',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Card
              if (widget.gamePost.description != null && widget.gamePost.description!.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.gamePost.description!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Join Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _viewModel.joinGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Join Game',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 