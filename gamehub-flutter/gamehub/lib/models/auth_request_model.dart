import 'package:json_annotation/json_annotation.dart';

part 'auth_request_model.g.dart';

@JsonSerializable()
class AuthRequestModel {
  final String identifier;
  final String password;

  AuthRequestModel({required this.identifier, required this.password});

  factory AuthRequestModel.fromJson(Map<String, dynamic> json) {
    return _$AuthRequestModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AuthRequestModelToJson(this);
}