import 'package:json_annotation/json_annotation.dart';

part 'game_post_request_model.g.dart';

@JsonSerializable()
class GamePostRequestModel {
  final int gameId;
  final String location;
  final double latitude;
  final double longitude;
  
  @JsonKey(toJson: _dateTimeToJson)
  final DateTime scheduledDate;
  
  final int maxParticipants;
  
  @JsonKey(required: false, includeIfNull: false)
  final String? description;

  GamePostRequestModel({
    required this.gameId,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.scheduledDate,
    required this.maxParticipants,
    this.description,
  });

  factory GamePostRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GamePostRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$GamePostRequestModelToJson(this);
  
  // Custom serialization for DateTime to ensure ISO 8601 format
  static String _dateTimeToJson(DateTime dateTime) {
    // Format as ISO 8601 with timezone
    return dateTime.toUtc().toIso8601String();
  }
} 