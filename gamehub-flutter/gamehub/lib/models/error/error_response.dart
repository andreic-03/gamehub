import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

@JsonSerializable()
class ErrorResponse {
  final String code;
  final String message;
  final List<String?> details;
  final String errorType;

  ErrorResponse({
    required this.code,
    required this.message,
    required this.details,
    required this.errorType,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}