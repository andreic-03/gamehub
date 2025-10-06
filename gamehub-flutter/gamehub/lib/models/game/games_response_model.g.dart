// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'games_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GamesResponseModel _$GamesResponseModelFromJson(Map<String, dynamic> json) =>
    GamesResponseModel(
      gameId: (json['gameId'] as num).toInt(),
      gameName: json['gameName'] as String,
      gameDescription: json['gameDescription'] as String,
      gameCategory: json['gameCategory'] as String,
    );

Map<String, dynamic> _$GamesResponseModelToJson(GamesResponseModel instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'gameName': instance.gameName,
      'gameDescription': instance.gameDescription,
      'gameCategory': instance.gameCategory,
    };
