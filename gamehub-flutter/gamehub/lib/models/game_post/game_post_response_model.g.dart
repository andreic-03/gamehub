// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_post_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GamePostResponseModel _$GamePostResponseModelFromJson(
  Map<String, dynamic> json,
) => GamePostResponseModel(
  postId: (json['postId'] as num).toInt(),
  hostName: json['hostName'] as String,
  gameId: (json['gameId'] as num).toInt(),
  gameName: json['gameName'] as String,
  gamePictureUrl: json['gamePictureUrl'] as String,
  location: json['location'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  scheduledDate: json['scheduledDate'] as String,
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$GamePostResponseModelToJson(
  GamePostResponseModel instance,
) => <String, dynamic>{
  'postId': instance.postId,
  'hostName': instance.hostName,
  'gameId': instance.gameId,
  'gameName': instance.gameName,
  'gamePictureUrl': instance.gamePictureUrl,
  'location': instance.location,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'scheduledDate': instance.scheduledDate,
  'maxParticipants': instance.maxParticipants,
  'description': instance.description,
};
