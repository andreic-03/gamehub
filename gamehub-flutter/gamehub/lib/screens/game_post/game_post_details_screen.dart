import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../core/utils/date_util.dart';
import '../../core/utils/error_util.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../../widgets/custom_back_button.dart';
import 'game_post_details_view_model.dart';
import 'update_game_post_screen.dart';

class GamePostDetailsScreen extends StatefulWidget {
  final GamePostResponseModel gamePost;
  final VoidCallback? onGameJoined;
  final int? currentUserId;

  const GamePostDetailsScreen({
    Key? key,
    required this.gamePost,
    this.onGameJoined,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<GamePostDetailsScreen> createState() => _GamePostDetailsScreenState();
}

class _GamePostDetailsScreenState extends State<GamePostDetailsScreen> {
  late GamePostDetailsViewModel _viewModel;
  late GamePostResponseModel _currentGamePost;

  @override
  void initState() {
    super.initState();
    _currentGamePost = widget.gamePost;
    _viewModel = GamePostDetailsViewModel(
      gamePost: _currentGamePost,
      onGameJoined: widget.onGameJoined,
      currentUserId: widget.currentUserId,
    );
  }

  Future<void> _navigateToEditScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateGamePostScreen(
          gamePost: _currentGamePost,
        ),
      ),
    );
    
    // If an updated game post was returned from the API, update the screen
    if (result is GamePostResponseModel) {
      setState(() {
        _currentGamePost = result;
        _viewModel = GamePostDetailsViewModel(
          gamePost: _currentGamePost,
          onGameJoined: widget.onGameJoined,
          currentUserId: widget.currentUserId,
        );
      });
      // Notify parent to refresh lists if needed
      widget.onGameJoined?.call();
    }
  }

  Future<void> _deleteGamePost(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: ListenableBuilder(
            listenable: LocalizationService.instance,
            builder: (context, child) {
              return Text('game_post_details.delete_confirmation_title'.localized);
            },
          ),
          content: ListenableBuilder(
            listenable: LocalizationService.instance,
            builder: (context, child) {
              return Text('game_post_details.delete_confirmation_message'.localized);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: ListenableBuilder(
                listenable: LocalizationService.instance,
                builder: (context, child) {
                  return Text('game_post_details.cancel'.localized);
                },
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: ListenableBuilder(
                listenable: LocalizationService.instance,
                builder: (context, child) {
                  return Text('game_post_details.delete'.localized);
                },
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await _viewModel.deleteGamePost();
      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ListenableBuilder(
              listenable: LocalizationService.instance,
              builder: (context, child) {
                return Text('game_post_details.deleted_successfully'.localized);
              },
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Notify parent to refresh lists
        widget.onGameJoined?.call();
        
        // Navigate back
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (!success && mounted && _viewModel.lastException != null) {
        // Display error using ErrorUtil
        ErrorUtil.showErrorSnackBar(context, _viewModel.lastException!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 120.0, 16.0, 16.0),
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
                                  _currentGamePost.location,
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
                                  DateUtil.formatScheduledDate(_currentGamePost.scheduledDate),
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
                                listenable: Listenable.merge([LocalizationService.instance, _viewModel]),
                                builder: (context, child) {
                                  return Text(
                                    'game_post_details.joined_participants_text'.localized
                                        .replaceAll('{current}', _viewModel.currentParticipantCount.toString())
                                        .replaceAll('{max}', _currentGamePost.maxParticipants.toString()),
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
              if (_currentGamePost.description != null && _currentGamePost.description!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: Card(
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
                            _currentGamePost.description!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                  const SizedBox(height: 24),

                  // Join Button
                  SizedBox(
                    width: double.infinity,
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, child) {
                        final isChecking = _viewModel.isCheckingJoinStatus;
                        final isLoading = _viewModel.isLoading;
                        return ElevatedButton(
                          onPressed: _viewModel.canJoinGame ? _viewModel.joinGame : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: _viewModel.hasJoined 
                                ? Colors.green 
                                : _viewModel.isGameFull 
                                    ? Colors.grey 
                                    : null,
                          ),
                          child: isLoading || isChecking
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : ListenableBuilder(
                                  listenable: LocalizationService.instance,
                                  builder: (context, child) {
                                    String buttonText;
                                    if (_viewModel.hasJoined) {
                                      buttonText = 'game_post_details.joined'.localized;
                                    } else if (_viewModel.isGameFull) {
                                      buttonText = 'game_post_details.game_full_button'.localized;
                                    } else {
                                      buttonText = 'game_post_details.join_game'.localized;
                                    }
                                    
                                    return Text(
                                      buttonText,
                                      style: const TextStyle(fontSize: 18),
                                    );
                                  },
                                ),
                        );
                      },
                    ),
                  ),

                  // Edit and Delete Buttons (only for hosts)
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, child) {
                      if (!_viewModel.isHost) return const SizedBox.shrink();
                      
                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _viewModel.isLoading ? null : () => _navigateToEditScreen(context),
                                  icon: const Icon(Icons.edit),
                                  label: ListenableBuilder(
                                    listenable: LocalizationService.instance,
                                    builder: (context, child) {
                                      return Text('game_post_details.edit_game_post'.localized);
                                    },
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _viewModel.isLoading ? null : () => _deleteGamePost(context),
                                  icon: const Icon(Icons.delete),
                                  label: ListenableBuilder(
                                    listenable: LocalizationService.instance,
                                    builder: (context, child) {
                                      return Text('game_post_details.delete_game_post'.localized);
                                    },
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  
                  // Error Message
                  if (_viewModel.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _viewModel.error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Custom back button
          CustomBackButton(
            heroTag: "game_post_details_back_button",
          ),
        ],
      ),
    );
  }
} 