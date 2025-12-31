// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdateRequestModel _$UserUpdateRequestModelFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(json, requiredKeys: const ['email', 'fullName']);
  return UserUpdateRequestModel(
    email: json['email'] as String,
    fullName: json['fullName'] as String,
    bio: json['bio'] as String?,
    profilePictureUrl: json['profilePictureUrl'] as String?,
  );
}

Map<String, dynamic> _$UserUpdateRequestModelToJson(
  UserUpdateRequestModel instance,
) => <String, dynamic>{
  'email': instance.email,
  'fullName': instance.fullName,
  'bio': instance.bio,
  'profilePictureUrl': instance.profilePictureUrl,
};
