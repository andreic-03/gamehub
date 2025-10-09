import 'package:json_annotation/json_annotation.dart';

part 'participants_request_model.g.dart';

@JsonSerializable()
class ParticipantsRequestModel {
  final int gamePostId;
  final ParticipantsStatus status;
  @JsonKey(name: 'isHost', defaultValue: false)
  final bool isHost;

  ParticipantsRequestModel({
    required this.gamePostId,
    required this.status,
    this.isHost = false,
  });

  factory ParticipantsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipantsRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantsRequestModelToJson(this);
}

enum ParticipantsStatus {
  @JsonValue('JOINED')
  joined,
  @JsonValue('INTERESTED')
  interested,
  @JsonValue('DECLINED')
  declined
}
