import 'package:flutter/material.dart';
import '../../localization/localization_service.dart';
import '../../models/message/message_model.dart';
import '../../widgets/custom_back_button.dart';
import 'chat_view_model.dart';

class ChatScreen extends StatefulWidget {
  final int gamePostId;

  const ChatScreen({
    Key? key,
    required this.gamePostId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const double _topPadding = 100.0;

  late ChatViewModel _viewModel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel(gamePostId: widget.gamePostId);
    _viewModel.addListener(_onViewModelUpdate);
    _connect();
  }

  void _connect() {
    _viewModel.connect();
  }

  void _onViewModelUpdate() {
    if (_viewModel.isConnected && _viewModel.messages.isNotEmpty) {
      // Scroll to bottom when new message arrives
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      _viewModel.sendMessage(message);
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${LocalizationService.instance.getString('chat.failed_to_send')}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate);
    _viewModel.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Chat messages area
              Expanded(
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, child) {
                    if (_viewModel.isConnecting) {
                      return Padding(
                        padding: EdgeInsets.only(top: _topPadding),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              if (_viewModel.isReconnecting) ...[
                                const SizedBox(height: 16),
                                Text(
                                  LocalizationService.instance.getString('chat.reconnecting'),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    if (_viewModel.error != null) {
                      return Padding(
                        padding: EdgeInsets.only(top: _topPadding),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _viewModel.error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _connect,
                                child: Text(LocalizationService.instance.getString('chat.retry_connection')),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (!_viewModel.isConnected) {
                      return Padding(
                        padding: EdgeInsets.only(top: _topPadding),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (_viewModel.messages.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: _topPadding),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              ListenableBuilder(
                                listenable: LocalizationService.instance,
                                builder: (context, child) {
                                  return Text(
                                    LocalizationService.instance.getString('chat.no_messages'),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(16, _topPadding, 16, 16),
                      itemCount: _viewModel.messages.length,
                      itemBuilder: (context, index) {
                        final message = _viewModel.messages[index];
                        final isCurrentUser = message.senderUsername ==
                            _viewModel.currentUsername;

                        return _buildMessageBubble(message, isCurrentUser);
                      },
                    );
                  },
                ),
              ),

              // Message input area
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  if (!_viewModel.isConnected) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: LocalizationService.instance.getString('chat.type_message'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Background barrier to hide scrolling content behind back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _topPadding,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),

          // Custom back button
          CustomBackButton(heroTag: 'chat_back_button'),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isCurrentUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade300,
              child: Text(
                message.senderUsername.isNotEmpty
                    ? message.senderUsername[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        message.senderUsername,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isCurrentUser
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  Text(
                    message.messageContent,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  if (message.sentAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _formatTime(message.sentAt!),
                        style: TextStyle(
                          fontSize: 10,
                          color: isCurrentUser
                              ? Colors.white70
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade300,
              child: Text(
                message.senderUsername.isNotEmpty
                    ? message.senderUsername[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      // Yesterday
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '${LocalizationService.instance.getString('chat.yesterday')} $hour:$minute';
    } else {
      // Older - show date and time
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day/$month $hour:$minute';
    }
  }
}


