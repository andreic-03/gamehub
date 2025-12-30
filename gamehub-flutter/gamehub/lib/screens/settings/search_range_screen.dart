import 'package:flutter/material.dart';
import '../../core/utils/location_cache.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../../widgets/custom_back_button.dart';

class SearchRangeScreen extends StatefulWidget {
  const SearchRangeScreen({super.key});

  @override
  State<SearchRangeScreen> createState() => _SearchRangeScreenState();
}

class _SearchRangeScreenState extends State<SearchRangeScreen> {
  static const double _topPadding = 100.0;

  late final TextEditingController _controller;
  double _rangeKm = 15.0;

  @override
  void initState() {
    super.initState();
    if (LocationCache.hasSearchRange && LocationCache.cachedSearchRangeInKm != null) {
      _rangeKm = LocationCache.cachedSearchRangeInKm!;
    }
    _controller = TextEditingController(text: _rangeKm.round().toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final parsed = double.tryParse(_controller.text);
    if (parsed == null || parsed < 0) {
      return;
    }
    LocationCache.setSearchRange(parsed);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, _topPadding, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Range Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'settings.search_range'.localized,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'settings.search_range'.localized,
                              prefixIcon: const Icon(Icons.tune),
                              suffix: ListenableBuilder(
                                listenable: LocalizationService.instance,
                                builder: (context, child) {
                                  return Text(' ${'home.km'.localized}');
                                },
                              ),
                              border: const UnderlineInputBorder(),
                              enabledBorder: const UnderlineInputBorder(),
                              focusedBorder: const UnderlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const LocalizedText('app.save'),
                    ),
                  ),
                ],
              ),
            ),
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
            heroTag: "search_range_back_button",
          ),
        ],
      ),
    );
  }
}


