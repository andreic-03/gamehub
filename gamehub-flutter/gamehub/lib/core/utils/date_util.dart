import 'package:intl/intl.dart';

class DateUtil {
  /// Formats a date string to the desired format: YYYY-MM-DD HH:MM
  /// Handles various input formats including ISO 8601
  static String formatScheduledDate(String dateString) {
    try {
      // Try to parse the date string
      DateTime dateTime;
      
      // Handle different possible input formats
      if (dateString.contains('T')) {
        // ISO 8601 format
        dateTime = DateTime.parse(dateString);
      } else if (dateString.contains(' ')) {
        // Space-separated format
        dateTime = DateTime.parse(dateString);
      } else {
        // Try parsing as-is
        dateTime = DateTime.parse(dateString);
      }
      
      // Format as YYYY-MM-DD HH:MM
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      // If parsing fails, return the original string
      print('Error parsing date: $dateString, error: $e');
      return dateString;
    }
  }
  
  /// Formats a DateTime object to the desired format: YYYY-MM-DD HH:MM
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
  
  /// Formats a DateTime object to date only: YYYY-MM-DD
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
