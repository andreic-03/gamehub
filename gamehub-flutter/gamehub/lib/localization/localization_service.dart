import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';
  
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();
  
  String _currentLanguage = _defaultLanguage;
  Map<String, dynamic> _localizedStrings = {};
  
  String get currentLanguage => _currentLanguage;
  
  /// Available languages
  static const Map<String, String> availableLanguages = {
    'en': 'English',
    'ro': 'Română',
    'fr': 'Français',
  };
  
  /// Initialize the localization service
  Future<void> initialize() async {
    await _loadLanguage();
    await _loadLocalizedStrings();
    // Notify listeners that initialization is complete
    notifyListeners();
  }
  
  /// Load saved language from SharedPreferences
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
  }
  
  /// Load localized strings for current language
  Future<void> _loadLocalizedStrings() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/localization/$_currentLanguage.json',
      );
      _localizedStrings = json.decode(jsonString);
    } catch (e) {
      print('Error loading localization file: $e');
      // Fallback to English if current language fails
      if (_currentLanguage != 'en') {
        _currentLanguage = 'en';
        final String jsonString = await rootBundle.loadString(
          'assets/localization/en.json',
        );
        _localizedStrings = json.decode(jsonString);
      }
    }
  }
  
  /// Change language and save to SharedPreferences
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _currentLanguage) return;
    
    _currentLanguage = languageCode;
    await _loadLocalizedStrings();
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    // Notify all listeners that the language has changed
    notifyListeners();
  }
  
  /// Get localized string by key
  String getString(String key) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;
    
    for (String k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if not found
      }
    }
    
    return value is String ? value : key;
  }
  
  /// Get localized string with fallback
  String getStringWithFallback(String key, String fallback) {
    final result = getString(key);
    return result == key ? fallback : result;
  }
}
