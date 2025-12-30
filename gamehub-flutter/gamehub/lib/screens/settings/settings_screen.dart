import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../config/injection.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../../widgets/custom_back_button.dart';
import 'change_password_screen.dart';
import 'settings_view_model.dart';
import '../../core/utils/location_cache.dart';
import 'search_range_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const double _topPadding = 120.0;

  late final SettingsViewModel _viewModel;
  late final LocalizationService _localizationService;
  double _rangeInKm = 15.0;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SettingsViewModel>();
    _localizationService = LocalizationService.instance;
    _viewModel.initialize();
    // Initialize range from cache if available
    if (LocationCache.hasSearchRange && LocationCache.cachedSearchRangeInKm != null) {
      _rangeInKm = LocationCache.cachedSearchRangeInKm!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              return ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, _topPadding, 16.0, 16.0),
                  children: [
                // Language Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocalizedText(
                          'settings.language',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _showLanguageDialog,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.language,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _viewModel.selectedLanguage,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Search Range Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocalizedText(
                          'settings.search_range',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchRangeScreen(),
                              ),
                            );
                            setState(() {
                              if (LocationCache.hasSearchRange && LocationCache.cachedSearchRangeInKm != null) {
                                _rangeInKm = LocationCache.cachedSearchRangeInKm!;
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.tune,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ListenableBuilder(
                                    listenable: LocalizationService.instance,
                                    builder: (context, child) {
                                      return Text(
                                        '${'settings.change_search_range'.localized}: ${_rangeInKm.round()} ${'home.km'.localized}',
                                        style: const TextStyle(fontSize: 16),
                                      );
                                    },
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Security Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocalizedText(
                          'settings.security',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: LocalizedText(
                                    'settings.change_password',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Future settings sections can be added here
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocalizedText(
                          'settings.more_settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const LocalizedText(
                          'settings.more_settings_description',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  ],
                );
            },
          ),
          // Background barrier to hide scrolling content behind back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _topPadding,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          // Custom back button
          CustomBackButton(
            heroTag: "settings_back_button",
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const LocalizedText('settings.select_language'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _viewModel.availableLanguages.length,
              itemBuilder: (context, index) {
                final languageCode = _viewModel.availableLanguages.keys.elementAt(index);
                final languageName = _viewModel.availableLanguages[languageCode]!;
                return ListTile(
                  title: Text(languageName),
                  trailing: _viewModel.selectedLanguageCode == languageCode
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () async {
                    await _viewModel.setLanguage(languageCode);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
