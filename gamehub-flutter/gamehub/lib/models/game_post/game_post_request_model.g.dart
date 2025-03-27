// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_post_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GamePostRequestModel _$GamePostRequestModelFromJson(
        Map<String, dynamic> json) =>
    GamePostRequestModel(
      gameId: (json['gameId'] as num).toInt(),
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$GamePostRequestModelToJson(
    GamePostRequestModel instance) {
  final val = <String, dynamic>{
    'gameId': instance.gameId,
    'location': instance.location,
    'latitude': instance.latitude,
    'longitude': instance.longitude,
    'scheduledDate':
        GamePostRequestModel._dateTimeToJson(instance.scheduledDate),
    'maxParticipants': instance.maxParticipants,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  return val;
}
