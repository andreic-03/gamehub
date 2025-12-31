import 'package:json_annotation/json_annotation.dart';

part 'user_update_request_model.g.dart';

@JsonSerializable()
class UserUpdateRequestModel {
  @JsonKey(name: 'email', required: true)
  final String email;

  @JsonKey(name: 'fullName', required: true)
  final String fullName;

  @JsonKey(name: 'bio')
  final String? bio;

  @JsonKey(name: 'profilePictureUrl')
  final String? profilePictureUrl;

  UserUpdateRequestModel({
    required this.email,
    required this.fullName,
    this.bio,
    this.profilePictureUrl,
  });

  factory UserUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateRequestModelToJson(this);
}
