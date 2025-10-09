import '../../core/viewmodels/base_view_model.dart';
import '../../localization/localization_service.dart';

class SettingsViewModel extends BaseViewModel {
  final LocalizationService _localizationService = LocalizationService.instance;

  /// Returns the currently selected language display name
  String get selectedLanguage => 
      LocalizationService.availableLanguages[_localizationService.currentLanguage] ?? 'English';

  /// Returns the currently selected language code
  String get selectedLanguageCode => _localizationService.currentLanguage;

  /// Sets the selected language
  Future<void> setLanguage(String languageCode) async {
    await _localizationService.changeLanguage(languageCode);
    notifyListeners();
  }

  /// Gets the list of available languages
  Map<String, String> get availableLanguages => LocalizationService.availableLanguages;

  /// Initializes the settings view model
  Future<void> initialize() async {
    // Initialize localization service if not already done
    await _localizationService.initialize();
    notifyListeners();
  }
}
