import 'package:json_annotation/json_annotation.dart';

part 'game_post_response_model.g.dart';

@JsonSerializable()
class GamePostResponseModel {
  final int postId;
  final int hostUserId;
  final int gameId;
  final String location;
  final double latitude;
  final double longitude;
  final String scheduledDate;
  final int maxParticipants;
  @JsonKey(required: false)
  final String description;

  GamePostResponseModel({
    required this.postId,
    required this.hostUserId,
    required this.gameId,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.scheduledDate,
    required this.maxParticipants,
    required this.description,
  });

  factory GamePostResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GamePostResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GamePostResponseModelToJson(this);
}