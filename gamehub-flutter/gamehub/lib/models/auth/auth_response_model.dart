import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final String username;
  final String accessToken;

  AuthResponseModel({required this.accessToken, required this.username});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return _$AuthResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}