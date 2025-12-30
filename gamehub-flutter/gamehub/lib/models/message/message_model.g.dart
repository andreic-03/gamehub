// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  gamePostId: (json['gamePostId'] as num?)?.toInt(),
  senderUsername: json['senderUsername'] as String,
  messageContent: json['messageContent'] as String,
  sentAt: json['sentAt'] == null
      ? null
      : DateTime.parse(json['sentAt'] as String),
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'gamePostId': instance.gamePostId,
      'senderUsername': instance.senderUsername,
      'messageContent': instance.messageContent,
      'sentAt': instance.sentAt?.toIso8601String(),
    };
