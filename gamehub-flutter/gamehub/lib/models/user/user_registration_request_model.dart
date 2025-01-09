import 'package:json_annotation/json_annotation.dart';

part 'user_registration_request_model.g.dart';

@JsonSerializable()
class UserRegistrationRequestModel {
  @JsonKey(required: true)
  final String username;

  @JsonKey(required: true)
  final String password;

  @JsonKey(required: true)
  final String email;

  @JsonKey(required: true)
  final String fullName;

  UserRegistrationRequestModel({
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
  });

  factory UserRegistrationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UserRegistrationRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserRegistrationRequestModelToJson(this);
}