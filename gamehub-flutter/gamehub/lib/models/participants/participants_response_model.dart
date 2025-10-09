import 'package:json_annotation/json_annotation.dart';

part 'participants_response_model.g.dart';

@JsonSerializable()
class ParticipantsResponseModel {
  final int participantId;
  final int gamePostId;
  final int userId;
  final ParticipantsStatus status;
  @JsonKey(name: 'joinedAt')
  final DateTime joinedAt;
  @JsonKey(name: 'isHost')
  final bool isHost;

  ParticipantsResponseModel({
    required this.participantId,
    required this.gamePostId,
    required this.userId,
    required this.status,
    required this.joinedAt,
    required this.isHost,
  });

  factory ParticipantsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipantsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantsResponseModelToJson(this);
}

enum ParticipantsStatus {
  @JsonValue('JOINED')
  joined,
  @JsonValue('INTERESTED')
  interested,
  @JsonValue('DECLINED')
  declined
}
