import 'package:json_annotation/json_annotation.dart';

part 'user_password_change_model.g.dart';

@JsonSerializable()
class UserPasswordChangeModel {
  @JsonKey(name: 'oldPassword', required: true)
  final String oldPassword;

  @JsonKey(name: 'newPassword', required: true)
  final String newPassword;

  UserPasswordChangeModel({
    required this.oldPassword,
    required this.newPassword,
  });

  factory UserPasswordChangeModel.fromJson(Map<String, dynamic> json) =>
      _$UserPasswordChangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPasswordChangeModelToJson(this);
}

