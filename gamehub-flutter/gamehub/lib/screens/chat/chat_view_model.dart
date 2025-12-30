import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/viewmodels/auth_view_model.dart';
import '../../models/message/message_model.dart';
import '../../network/network_constants.dart';
import '../../core/utils/user_cache.dart';
import '../../config/injection.dart';
import '../../services/messages/messages_service.dart';

enum ConnectionState { disconnected, connecting, connected, reconnecting, error }

class ChatViewModel extends ChangeNotifier {
  // Timing Constants
  static const int _connectionTimeoutMs = 1500;
  static const int _stompConnectTimeoutMs = 5000;
  static const int _subscriptionDelayMs = 200;
  static const int _duplicateWindowMs = 10000;
  static const int _exactDuplicateWindowMs = 2000;
  static const String _nullTerminator = '\x00';

  // Dependencies
  final int gamePostId;
  final String? currentUsername;
  final MessagesService _messagesService = getIt<MessagesService>();

  // WebSocket state
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  ConnectionState _connectionState = ConnectionState.disconnected;
  String? _error;
  final List<MessageModel> _messages = [];

  // STOMP state
  int _messageIdCounter = 0;
  bool _connectFrameSent = false;
  final Set<String> _pendingMessageIds = {};
  bool _messagesLoaded = false;
  bool _hasTriedWithoutApi = false;
  String? _authToken; // Stored for STOMP authentication

  // Reconnection state
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  // Getters
  bool get isConnected => _connectionState == ConnectionState.connected;
  bool get isConnecting =>
      _connectionState == ConnectionState.connecting ||
      _connectionState == ConnectionState.reconnecting;
  bool get isReconnecting => _connectionState == ConnectionState.reconnecting;
  ConnectionState get connectionState => _connectionState;
  String? get error => _error;
  List<MessageModel> get messages => List.unmodifiable(_messages);

  ChatViewModel({required this.gamePostId})
      : currentUsername = UserCache.cachedUser?.username;

  Future<void> connect() async {
    if (_connectionState == ConnectionState.connected ||
        _connectionState == ConnectionState.connecting) {
      return;
    }

    _reconnectAttempts = 0;
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    try {
      _connectionState = _reconnectAttempts > 0
          ? ConnectionState.reconnecting
          : ConnectionState.connecting;
      _error = null;
      notifyListeners();

      if (!_messagesLoaded) {
        await _loadExistingMessages();
      }

      _authToken = _getAuthToken();
      if (_authToken == null) {
        throw Exception('No authentication token available');
      }

      // Build URL without token - authentication happens via STOMP headers
      final wsUrl = _buildWebSocketUrl(withApiPrefix: true);
      _connectFrameSent = false;
      _hasTriedWithoutApi = false;

      _channel = WebSocketChannel.connect(wsUrl);
      _setupStreamListener();
      _scheduleStompConnect();
    } catch (e) {
      _handleConnectionError('Failed to connect: ${e.toString()}');
    }
  }

  String? _getAuthToken() {
    final authViewModel = GetIt.instance<AuthViewModel>();
    final token = authViewModel.token;
    return (token != null && token.isNotEmpty) ? token : null;
  }

  /// Builds WebSocket URL without token in query params.
  /// Token is sent securely via STOMP Authorization header instead.
  Uri _buildWebSocketUrl({required bool withApiPrefix}) {
    final uri = Uri.parse(NetworkConstants.baseURL);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final path = withApiPrefix
        ? NetworkConstants.wsEndpointWithApi
        : NetworkConstants.wsEndpointWithoutApi;

    return Uri(
      scheme: wsScheme,
      host: uri.host,
      port: uri.port,
      path: path,
    );
  }

  void _setupStreamListener() {
    _subscription = _channel!.stream.listen(
      _handleIncomingMessage,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: false,
    );
  }

  void _handleIncomingMessage(dynamic message) {
    if (!_connectFrameSent) {
      _connectFrameSent = true;
      _sendStompConnect();
    }
    _onMessage(message);
  }

  void _scheduleStompConnect() {
    Future.delayed(const Duration(milliseconds: _connectionTimeoutMs), () {
      if (!_connectFrameSent &&
          _channel != null &&
          _connectionState != ConnectionState.connected) {
        _connectFrameSent = true;
        _sendStompConnect();
      }
    });
  }

  void _sendStompConnect() {
    if (_authToken == null) {
      _handleConnectionError('No authentication token available');
      return;
    }

    // Send token securely via STOMP Authorization header (not URL query params)
    final connectFrame = _buildStompFrame('CONNECT', {
      'accept-version': NetworkConstants.stompAcceptVersion,
      'heart-beat': NetworkConstants.stompHeartBeat,
      'Authorization': 'Bearer $_authToken',
    });

    if (!_sendFrame(connectFrame)) return;

    Future.delayed(const Duration(milliseconds: _stompConnectTimeoutMs), () {
      if (_connectionState != ConnectionState.connected &&
          (_connectionState == ConnectionState.connecting ||
              _connectionState == ConnectionState.reconnecting)) {
        _handleConnectionError('STOMP connection timeout');
      }
    });
  }

  String _buildStompFrame(String command, Map<String, String> headers,
      [String? body]) {
    final buffer = StringBuffer()..writeln(command);

    for (final entry in headers.entries) {
      buffer.writeln('${entry.key}:${entry.value}');
    }

    buffer.writeln();

    if (body != null) {
      buffer.write(body);
    }

    buffer.write(_nullTerminator);
    return buffer.toString();
  }

  bool _sendFrame(String frame) {
    if (_channel == null) {
      _handleConnectionError('WebSocket channel is null');
      return false;
    }

    try {
      _channel!.sink.add(frame);
      return true;
    } catch (e) {
      _handleConnectionError('Failed to send frame: ${e.toString()}');
      return false;
    }
  }

  void _onMessage(dynamic message) {
    try {
      final messageStr = _parseMessageToString(message);

      if (_handleConnectedFrame(messageStr)) return;
      if (_handleMessageFrame(messageStr)) return;
      if (_handleErrorFrame(messageStr)) return;
      _tryParseDirectJson(messageStr);
    } catch (e) {
      // Silently handle parsing errors
    }
  }

  String _parseMessageToString(dynamic message) {
    if (message is String) return message;
    if (message is List<int>) return String.fromCharCodes(message);
    return message.toString();
  }

  bool _handleConnectedFrame(String messageStr) {
    if (!messageStr.startsWith('CONNECTED') &&
        !messageStr.contains('CONNECTED\n')) {
      return false;
    }

    _connectionState = ConnectionState.connected;
    _error = null;
    _reconnectAttempts = 0;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: _subscriptionDelayMs), () {
      _subscribeToTopic();
    });

    return true;
  }

  bool _handleMessageFrame(String messageStr) {
    final trimmedMsg = messageStr.trim();
    final isMessageFrame =
        trimmedMsg.startsWith('MESSAGE') || messageStr.contains('MESSAGE\n');

    if (!isMessageFrame) return false;

    final body = _extractMessageBody(messageStr);
    if (body == null || body.isEmpty) return true;

    try {
      final messageJson = jsonDecode(body);
      final message = MessageModel.fromJson(messageJson);
      _addMessageWithDeduplication(message);
    } catch (e) {
      // Failed to parse message body
    }

    return true;
  }

  String? _extractMessageBody(String messageStr) {
    final lines = messageStr.split('\n');
    int bodyStartIndex = -1;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isEmpty && i < lines.length - 1) {
        bodyStartIndex = i + 1;
        break;
      }
    }

    if (bodyStartIndex == -1 || bodyStartIndex >= lines.length) return null;

    final body = lines.sublist(bodyStartIndex).join('\n');
    return body.replaceAll(_nullTerminator, '').trim();
  }

  void _addMessageWithDeduplication(MessageModel message) {
    final foundDuplicate = _removeOptimisticDuplicate(message);
    _pendingMessageIds
        .removeWhere((id) => id.startsWith(message.messageContent));

    if (!foundDuplicate && !_isDuplicateFromRestApi(message)) {
      _messages.add(message);
    } else if (foundDuplicate) {
      _messages.add(message);
    }

    _sortMessages();
    notifyListeners();
  }

  bool _removeOptimisticDuplicate(MessageModel message) {
    bool foundDuplicate = false;

    _messages.removeWhere((existing) {
      if (existing.messageContent == message.messageContent &&
          existing.senderUsername == message.senderUsername &&
          existing.gamePostId == message.gamePostId) {
        if (existing.sentAt == null || message.sentAt == null) {
          foundDuplicate = true;
          return true;
        }

        final timeDiff = (existing.sentAt!.millisecondsSinceEpoch -
                message.sentAt!.millisecondsSinceEpoch)
            .abs();
        if (timeDiff < _duplicateWindowMs) {
          foundDuplicate = true;
          return true;
        }
      }
      return false;
    });

    return foundDuplicate;
  }

  bool _isDuplicateFromRestApi(MessageModel message) {
    return _messages.any((m) =>
        m.messageContent == message.messageContent &&
        m.senderUsername == message.senderUsername &&
        m.gamePostId == message.gamePostId &&
        m.sentAt != null &&
        message.sentAt != null &&
        (m.sentAt!.millisecondsSinceEpoch -
                    message.sentAt!.millisecondsSinceEpoch)
                .abs() <
            _exactDuplicateWindowMs);
  }

  void _sortMessages() {
    _messages.sort((a, b) {
      if (a.sentAt == null && b.sentAt == null) return 0;
      if (a.sentAt == null) return 1;
      if (b.sentAt == null) return -1;
      return a.sentAt!.compareTo(b.sentAt!);
    });
  }

  bool _handleErrorFrame(String messageStr) {
    if (!messageStr.startsWith('ERROR') && !messageStr.contains('ERROR\n')) {
      return false;
    }

    _handleConnectionError('STOMP error: $messageStr');
    return true;
  }

  void _tryParseDirectJson(String messageStr) {
    final trimmed = messageStr.trim().replaceAll(_nullTerminator, '');
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) return;

    try {
      final messageJson = jsonDecode(trimmed);
      final message = MessageModel.fromJson(messageJson);

      if (!_isDuplicateFromRestApi(message)) {
        _messages.add(message);
        _sortMessages();
        notifyListeners();
      }
    } catch (e) {
      // Not valid JSON
    }
  }

  Future<void> _loadExistingMessages() async {
    try {
      final existingMessages =
          await _messagesService.getMessagesByGamePostId(gamePostId);
      _messages.addAll(existingMessages);
      _sortMessages();
      _messagesLoaded = true;
      notifyListeners();
    } catch (e) {
      _messagesLoaded = true;
    }
  }

  void _subscribeToTopic() {
    if (_connectionState != ConnectionState.connected || _channel == null) {
      return;
    }

    final subscriptionId = 'sub-${DateTime.now().millisecondsSinceEpoch}';
    final topic = '${NetworkConstants.stompTopicPrefix}$gamePostId';

    final subscribeFrame = _buildStompFrame('SUBSCRIBE', {
      'id': subscriptionId,
      'destination': topic,
    });

    _sendFrame(subscribeFrame);
  }

  void _onError(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('was not upgraded') && !_hasTriedWithoutApi) {
      _hasTriedWithoutApi = true;
      _retryConnectionWithoutApi();
      return;
    }

    _handleConnectionError('WebSocket error: $errorStr');
  }

  void _retryConnectionWithoutApi() async {
    try {
      await _closeChannel();

      _authToken = _getAuthToken();
      if (_authToken == null) {
        _handleConnectionError('No authentication token available');
        return;
      }

      final wsUrl = _buildWebSocketUrl(withApiPrefix: false);
      _channel = WebSocketChannel.connect(wsUrl);
      _setupStreamListener();

      Future.delayed(
        Duration(milliseconds: NetworkConstants.initialReconnectDelayMs),
        () {
          if (_channel != null &&
              _connectionState != ConnectionState.connected) {
            _sendStompConnect();
          }
        },
      );
    } catch (e) {
      _handleConnectionError('Failed to retry connection: ${e.toString()}');
    }
  }

  void _onDone() {
    final wasConnected = _connectionState == ConnectionState.connected;
    _connectionState = ConnectionState.disconnected;
    notifyListeners();

    // Attempt automatic reconnection if we were previously connected
    if (wasConnected) {
      _scheduleReconnect();
    }
  }

  void _handleConnectionError(String errorMessage) {
    _error = errorMessage;
    _connectionState = ConnectionState.error;
    notifyListeners();

    // Attempt automatic reconnection
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= NetworkConstants.maxReconnectAttempts) {
      _error = 'Connection failed after ${NetworkConstants.maxReconnectAttempts} attempts';
      _connectionState = ConnectionState.error;
      notifyListeners();
      return;
    }

    _reconnectTimer?.cancel();

    // Exponential backoff: delay = min(initialDelay * 2^attempts, maxDelay)
    final delay = min(
      NetworkConstants.initialReconnectDelayMs *
          pow(2, _reconnectAttempts).toInt(),
      NetworkConstants.maxReconnectDelayMs,
    );

    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(milliseconds: delay), () async {
      await _closeChannel();
      await _establishConnection();
    });
  }

  Future<void> _closeChannel() async {
    _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } catch (e) {
      // Ignore close errors
    }
    _channel = null;
  }

  void sendMessage(String messageContent) {
    if (_connectionState != ConnectionState.connected || _channel == null) {
      throw Exception('Not connected to chat');
    }

    final trimmedContent = messageContent.trim();
    if (trimmedContent.isEmpty) return;

    try {
      _addOptimisticMessage(trimmedContent);
      _sendMessageToServer(trimmedContent);
    } catch (e) {
      _removeLastOptimisticMessage(trimmedContent);
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  void _addOptimisticMessage(String content) {
    final now = DateTime.now();
    final optimisticMessage = MessageModel(
      gamePostId: gamePostId,
      messageContent: content,
      senderUsername: currentUsername ?? 'Unknown',
      sentAt: now,
    );

    _messages.add(optimisticMessage);
    _sortMessages();
    _pendingMessageIds.add('${content}_${now.millisecondsSinceEpoch}');
    notifyListeners();
  }

  void _sendMessageToServer(String content) {
    final messageToSend = MessageModel(
      gamePostId: gamePostId,
      messageContent: content,
      senderUsername: currentUsername ?? 'Unknown',
    );

    final messageId = 'msg-${++_messageIdCounter}';
    final body = jsonEncode(messageToSend.toJson());

    final sendFrame = _buildStompFrame(
      'SEND',
      {
        'id': messageId,
        'destination': NetworkConstants.stompSendDestination,
        'content-type': 'application/json',
      },
      body,
    );

    _channel!.sink.add(sendFrame);
  }

  void _removeLastOptimisticMessage(String content) {
    if (_messages.isNotEmpty && _messages.last.messageContent == content) {
      _messages.removeLast();
      notifyListeners();
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_channel != null && _connectionState == ConnectionState.connected) {
      final disconnectFrame = _buildStompFrame('DISCONNECT', {});
      try {
        _channel!.sink.add(disconnectFrame);
      } catch (e) {
        // Ignore send errors during disconnect
      }
    }

    _subscription?.cancel();
    _channel?.sink.close();
    _resetState();
    notifyListeners();
  }

  void _resetState() {
    _channel = null;
    _subscription = null;
    _connectionState = ConnectionState.disconnected;
    _pendingMessageIds.clear();
    _messagesLoaded = false;
    _reconnectAttempts = 0;
    _authToken = null; // Clear token for security
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
