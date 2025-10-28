// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_password_change_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPasswordChangeModel _$UserPasswordChangeModelFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(json, requiredKeys: const ['oldPassword', 'newPassword']);
  return UserPasswordChangeModel(
    oldPassword: json['oldPassword'] as String,
    newPassword: json['newPassword'] as String,
  );
}

Map<String, dynamic> _$UserPasswordChangeModelToJson(
  UserPasswordChangeModel instance,
) => <String, dynamic>{
  'oldPassword': instance.oldPassword,
  'newPassword': instance.newPassword,
};
