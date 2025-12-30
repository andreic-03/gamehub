import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gamehub/localization/localized_text.dart';
import '../errors/api_error.dart';
import '../../localization/localization_service.dart';

class ErrorUtil {
  /// Logs error details only in debug mode
  static void _logError(Object error) {
    if (!kDebugMode) return;

    debugPrint('ErrorUtil received error: ${error.runtimeType}');
    if (error is Map) {
      debugPrint('Error data: ${jsonEncode(error)}');
    } else if (error is DioException) {
      debugPrint('DioError type: ${error.type}');
      debugPrint('DioError message: ${error.message}');
      if (error.response != null) {
        debugPrint('Response status: ${error.response?.statusCode}');
      }
    } else {
      debugPrint('Error details: $error');
    }
  }

  /// Displays an error dialog with the formatted error message
  static void showErrorDialog(BuildContext context, Object error) {
    _logError(error);

    ApiError apiError = _parseError(error);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(apiError.message),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (apiError.details.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...apiError.details.map((detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(detail)),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: ListenableBuilder(
              listenable: LocalizationService.instance,
              builder: (context, child) {
                return Text('error.ok'.localized);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Displays a snackbar with the formatted error message
  static void showErrorSnackBar(BuildContext context, Object error) {
    _logError(error);

    ApiError apiError = _parseError(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(apiError.userFriendlyMessage),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'error.dismiss'.localized,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Parses various error types into a standardized ApiError
  static ApiError _parseError(Object error) {
    try {
      if (error is ApiError) {
        return error;
      } else if (error is DioException) {
        return ApiError.fromDioError(error);
      } else if (error is Map) {
        try {
          Map<String, dynamic> errorMap = {};
          error.forEach((key, value) {
            errorMap[key.toString()] = value;
          });
          return ApiError.fromJson(errorMap);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error parsing Map error: $e');
          }
          return ApiError(
            code: 'PARSE_ERROR',
            message: 'Error Format',
            details: ['Failed to parse error data: ${error.toString()}'],
            errorType: 'CLIENT_ERROR',
          );
        }
      } else {
        return ApiError(
          code: 'UNEXPECTED_ERROR',
          message: 'Unexpected Error',
          details: [error.toString()],
          errorType: 'UNKNOWN',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Exception in _parseError: $e');
      }
      return ApiError(
        code: 'ERROR_PARSER_FAILED',
        message: 'Error Processing',
        details: ['Failed to process error: $e'],
        errorType: 'INTERNAL_ERROR',
      );
    }
  }
}
