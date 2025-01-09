import 'package:json_annotation/json_annotation.dart';

part 'user_response_model.g.dart';

@JsonSerializable()
class UserResponseModel {
  final int id;
  final String username;
  final String email;
  final UserStatus status;
  final String fullName;
  final String? bio;
  final String? profilePictureUrl;
  @JsonKey(name: 'lastLogin')
  final DateTime? lastLogin;
  final Set<String> roles;

  UserResponseModel({
    required this.id,
    required this.username,
    required this.email,
    required this.status,
    required this.fullName,
    this.bio,
    this.profilePictureUrl,
    this.lastLogin,
    required this.roles,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) => _$UserResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseModelToJson(this);
}

enum UserStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('SUSPENDED')
  suspended
}