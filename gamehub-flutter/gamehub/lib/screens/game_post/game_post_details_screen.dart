import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../core/utils/date_util.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
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
        title: const LocalizedText('game_post_details.title'),
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
                      const LocalizedText(
                        'game_post_details.location',
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
                      const LocalizedText(
                        'game_post_details.date_time',
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
                              DateUtil.formatScheduledDate(widget.gamePost.scheduledDate),
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
                      const LocalizedText(
                        'game_post_details.participants',
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
                          ListenableBuilder(
                            listenable: LocalizationService.instance,
                            builder: (context, child) {
                              return Text(
                                'game_post_details.max_participants_text'.localized.replaceAll('{count}', widget.gamePost.maxParticipants.toString()),
                                style: const TextStyle(fontSize: 16),
                              );
                            },
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
                        const LocalizedText(
                          'game_post_details.description',
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
                  child: ListenableBuilder(
                    listenable: LocalizationService.instance,
                    builder: (context, child) {
                      return Text(
                        'game_post_details.join_game'.localized,
                        style: const TextStyle(fontSize: 18),
                      );
                    },
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