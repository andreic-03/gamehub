import 'package:json_annotation/json_annotation.dart';

part 'game_post_response_model.g.dart';

@JsonSerializable()
class GamePostResponseModel {
  final int postId;
  final String hostName;
  final int gameId;
  final String gameName;
  final String gamePictureUrl;
  final String location;
  final double latitude;
  final double longitude;
  final String scheduledDate;
  final int maxParticipants;
  final int currentParticipantCount;
  final String? description;

  GamePostResponseModel({
    required this.postId,
    required this.hostName,
    required this.gameId,
    required this.gameName,
    required this.gamePictureUrl,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.scheduledDate,
    required this.maxParticipants,
    required this.currentParticipantCount,
    this.description,
  });

  factory GamePostResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GamePostResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GamePostResponseModelToJson(this);
}