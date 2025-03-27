import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

@JsonSerializable()
class ErrorResponse {
  final String code;
  final String message;
  @JsonKey(fromJson: _detailsFromJson)
  final List<String> details;
  final String errorType;

  ErrorResponse({
    required this.code,
    required this.message,
    required this.details,
    required this.errorType,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  // Custom JSON converter for details field
  static List<String> _detailsFromJson(dynamic details) {
    if (details == null) return [];
    
    if (details is List) {
      return details.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }
    
    if (details is String) {
      return [details];
    }
    
    return [];
  }
}