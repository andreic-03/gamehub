import 'dart:convert';

import 'package:dio/dio.dart';

class ApiError {
  final String code;
  final String message;
  final List<String> details;
  final String errorType;

  ApiError({
    required this.code,
    required this.message,
    required this.details,
    required this.errorType,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    List<String> detailsList = [];
    
    // Handle details field which can be null, a string, or a list of strings
    if (json['details'] != null) {
      if (json['details'] is List) {
        detailsList = (json['details'] as List)
            .map((e) => e?.toString() ?? 'Unknown error')
            .toList();
      } else if (json['details'] is String) {
        detailsList = [json['details'] as String];
      } else {
        // Handle case where details is some other type (e.g., Map)
        detailsList = [json['details'].toString()];
      }
    }

    // Safely extract string fields with fallbacks for null values
    String code = 'UNKNOWN_ERROR';
    if (json['code'] != null) {
      code = json['code'].toString();
    }
    
    String message = 'An unknown error occurred';
    if (json['message'] != null) {
      message = json['message'].toString();
    }
    
    String errorType = 'UNKNOWN';
    if (json['errorType'] != null) {
      errorType = json['errorType'].toString();
    }

    return ApiError(
      code: code,
      message: message,
      details: detailsList,
      errorType: errorType,
    );
  }

  factory ApiError.fromDioError(DioException error) {
    // Try to parse error response if available
    if (error.response != null && error.response!.data != null) {
      try {
        var data = error.response!.data;
        
        // Handle string data
        if (data is String) {
          // Try to parse it as JSON
          try {
            data = jsonDecode(data);
          } catch (_) {
            // If it's not valid JSON, use it as a message
            return ApiError(
              code: 'HTTP_ERROR_${error.response!.statusCode}',
              message: 'Server Error',
              details: [data],
              errorType: 'SERVER_ERROR',
            );
          }
        }
        
        // Handle map data
        if (data is Map) {
          try {
            return ApiError.fromJson(data.cast<String, dynamic>());
          } catch (e) {
            print('Error parsing API error: $e');
            // Create a fallback error with the available information
            return ApiError(
              code: 'PARSE_ERROR',
              message: 'Error parsing server response',
              details: ['Server returned invalid error format: ${data.toString()}'],
              errorType: 'CLIENT_ERROR',
            );
          }
        }
      } catch (e) {
        print('Error handling API error: $e');
      }
    }

    // Default error based on status code
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      switch (statusCode) {
        case 400:
          return ApiError(
            code: 'BAD_REQUEST',
            message: 'Bad Request',
            details: ['The request was invalid or cannot be otherwise served.'],
            errorType: 'CLIENT_ERROR',
          );
        case 401:
          return ApiError(
            code: 'UNAUTHORIZED',
            message: 'Unauthorized',
            details: ['Authentication is required and has failed or has not been provided.'],
            errorType: 'AUTH_ERROR',
          );
        case 403:
          return ApiError(
            code: 'FORBIDDEN',
            message: 'Forbidden',
            details: ['You don\'t have permission to access this resource.'],
            errorType: 'AUTH_ERROR',
          );
        case 404:
          return ApiError(
            code: 'NOT_FOUND',
            message: 'Not Found',
            details: ['The requested resource could not be found.'],
            errorType: 'CLIENT_ERROR',
          );
        case 500:
          return ApiError(
            code: 'SERVER_ERROR',
            message: 'Server Error',
            details: ['An error occurred on the server.'],
            errorType: 'SERVER_ERROR',
          );
        default:
          return ApiError(
            code: 'HTTP_ERROR_$statusCode',
            message: 'HTTP Error $statusCode',
            details: ['An error occurred while communicating with the server.'],
            errorType: 'NETWORK_ERROR',
          );
      }
    }

    // Handle other types of errors
    if (error.type == DioExceptionType.connectionTimeout) {
      return ApiError(
        code: 'CONNECTION_TIMEOUT',
        message: 'Connection Timeout',
        details: ['The connection to the server timed out.'],
        errorType: 'NETWORK_ERROR',
      );
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return ApiError(
        code: 'RECEIVE_TIMEOUT',
        message: 'Receive Timeout',
        details: ['The server took too long to respond.'],
        errorType: 'NETWORK_ERROR',
      );
    } else if (error.type == DioExceptionType.sendTimeout) {
      return ApiError(
        code: 'SEND_TIMEOUT',
        message: 'Send Timeout',
        details: ['The request took too long to send.'],
        errorType: 'NETWORK_ERROR',
      );
    } else if (error.type == DioExceptionType.connectionError) {
      return ApiError(
        code: 'CONNECTION_ERROR',
        message: 'Connection Error',
        details: ['Could not connect to the server.'],
        errorType: 'NETWORK_ERROR',
      );
    }

    // Generic error for other cases
    return ApiError(
      code: 'UNKNOWN_ERROR',
      message: 'Unknown Error',
      details: [error.message ?? 'An unknown error occurred'],
      errorType: 'UNKNOWN',
    );
  }

  String get userFriendlyMessage {
    // Format a user-friendly message that includes details when available
    String baseMessage = message;
    
    if (details.isNotEmpty) {
      if (details.length == 1) {
        baseMessage += ': ${details.first}';
      } else {
        baseMessage += ':\n• ' + details.join('\n• ');
      }
    }
    
    return baseMessage;
  }
} 