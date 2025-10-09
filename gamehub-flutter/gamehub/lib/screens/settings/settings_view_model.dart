import '../../core/viewmodels/base_view_model.dart';

class SettingsViewModel extends BaseViewModel {
  String _selectedLanguage = 'English';

  /// Returns the currently selected language
  String get selectedLanguage => _selectedLanguage;

  /// Sets the selected language
  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  /// Gets the list of available languages
  List<String> get availableLanguages => [
    'English',
    'Romanian',
    'French',
  ];

  /// Initializes the settings view model
  Future<void> initialize() async {
    // For now, just set default values
    // Future: Load saved settings from SharedPreferences or other storage
    // No loading state needed for current implementation
  }
}
