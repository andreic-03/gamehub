// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_registration_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRegistrationRequestModel _$UserRegistrationRequestModelFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['username', 'password', 'email', 'fullName'],
  );
  return UserRegistrationRequestModel(
    username: json['username'] as String,
    password: json['password'] as String,
    email: json['email'] as String,
    fullName: json['fullName'] as String,
  );
}

Map<String, dynamic> _$UserRegistrationRequestModelToJson(
        UserRegistrationRequestModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'email': instance.email,
      'fullName': instance.fullName,
    };
