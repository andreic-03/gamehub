import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final int? gamePostId;
  final String senderUsername;
  final String messageContent;
  @JsonKey(name: 'sentAt')
  final DateTime? sentAt;

  MessageModel({
    this.gamePostId,
    required this.senderUsername,
    required this.messageContent,
    this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle Java Timestamp format (epoch milliseconds)
    if (json['sentAt'] != null) {
      if (json['sentAt'] is int) {
        // Convert epoch milliseconds to DateTime
        json['sentAt'] = DateTime.fromMillisecondsSinceEpoch(json['sentAt'] as int).toIso8601String();
      } else if (json['sentAt'] is String) {
        // Already a string, try to parse it
        final sentAtStr = json['sentAt'] as String;
        try {
          // Try parsing as ISO 8601 string first
          DateTime.parse(sentAtStr);
          // If successful, keep it as is
        } catch (e) {
          // If parsing fails, try as epoch milliseconds
          try {
            final timestamp = int.parse(sentAtStr);
            json['sentAt'] = DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String();
          } catch (_) {
            // If both fail, try parsing timestamp from array format [seconds, nanoseconds]
            // Sometimes Spring serializes Timestamp as [epochSeconds, nanoseconds]
            if (sentAtStr.startsWith('[') && sentAtStr.endsWith(']')) {
              try {
                final parts = sentAtStr.substring(1, sentAtStr.length - 1).split(',');
                if (parts.length >= 1) {
                  final seconds = int.parse(parts[0].trim());
                  json['sentAt'] = DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toIso8601String();
                } else {
                  json['sentAt'] = null;
                }
              } catch (_) {
                json['sentAt'] = null;
              }
            } else {
              json['sentAt'] = null;
            }
          }
        }
      } else if (json['sentAt'] is List) {
        // Handle array format [seconds, nanoseconds] that Spring sometimes uses
        final sentAtList = json['sentAt'] as List;
        if (sentAtList.isNotEmpty && sentAtList[0] is int) {
          final seconds = sentAtList[0] as int;
          json['sentAt'] = DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toIso8601String();
        } else {
          json['sentAt'] = null;
        }
      }
    }
    return _$MessageModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}

