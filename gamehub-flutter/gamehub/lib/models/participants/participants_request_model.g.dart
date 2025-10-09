// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participants_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParticipantsRequestModel _$ParticipantsRequestModelFromJson(
  Map<String, dynamic> json,
) => ParticipantsRequestModel(
  gamePostId: (json['gamePostId'] as num).toInt(),
  status: $enumDecode(_$ParticipantsStatusEnumMap, json['status']),
  isHost: json['isHost'] as bool? ?? false,
);

Map<String, dynamic> _$ParticipantsRequestModelToJson(
  ParticipantsRequestModel instance,
) => <String, dynamic>{
  'gamePostId': instance.gamePostId,
  'status': _$ParticipantsStatusEnumMap[instance.status]!,
  'isHost': instance.isHost,
};

const _$ParticipantsStatusEnumMap = {
  ParticipantsStatus.joined: 'JOINED',
  ParticipantsStatus.interested: 'INTERESTED',
  ParticipantsStatus.declined: 'DECLINED',
};
