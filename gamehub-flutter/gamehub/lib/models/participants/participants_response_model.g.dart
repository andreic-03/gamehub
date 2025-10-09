// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participants_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParticipantsResponseModel _$ParticipantsResponseModelFromJson(
  Map<String, dynamic> json,
) => ParticipantsResponseModel(
  participantId: (json['participantId'] as num).toInt(),
  gamePostId: (json['gamePostId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  status: $enumDecode(_$ParticipantsStatusEnumMap, json['status']),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  isHost: json['isHost'] as bool,
);

Map<String, dynamic> _$ParticipantsResponseModelToJson(
  ParticipantsResponseModel instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'gamePostId': instance.gamePostId,
  'userId': instance.userId,
  'status': _$ParticipantsStatusEnumMap[instance.status]!,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'isHost': instance.isHost,
};

const _$ParticipantsStatusEnumMap = {
  ParticipantsStatus.joined: 'JOINED',
  ParticipantsStatus.interested: 'INTERESTED',
  ParticipantsStatus.declined: 'DECLINED',
};
