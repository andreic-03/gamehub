import 'package:json_annotation/json_annotation.dart';

part 'games_response_model.g.dart';

@JsonSerializable()
class GamesResponseModel {
  final int gameId;
  final String gameName;
  final String gameDescription;
  final String gameCategory;

  GamesResponseModel({
    required this.gameId,
    required this.gameName,
    required this.gameDescription,
    required this.gameCategory,
  });

  factory GamesResponseModel.fromJson(Map<String, dynamic> json) => _$GamesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GamesResponseModelToJson(this);
}
