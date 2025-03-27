// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_post_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GamePostResponseModel _$GamePostResponseModelFromJson(
        Map<String, dynamic> json) =>
    GamePostResponseModel(
      postId: (json['postId'] as num).toInt(),
      hostUserId: (json['hostUserId'] as num).toInt(),
      gameId: (json['gameId'] as num).toInt(),
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      scheduledDate: json['scheduledDate'] as String,
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$GamePostResponseModelToJson(
        GamePostResponseModel instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'hostUserId': instance.hostUserId,
      'gameId': instance.gameId,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'scheduledDate': instance.scheduledDate,
      'maxParticipants': instance.maxParticipants,
      'description': instance.description,
    };
