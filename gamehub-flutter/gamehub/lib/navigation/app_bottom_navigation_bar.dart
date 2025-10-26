import 'package:flutter/material.dart';
import '../localization/localized_text.dart';
import '../localization/localization_service.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final bool isRefreshing;

  const AppBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isRefreshing = false,
  }) : super(key: key);

  @override
  _AppBottomNavigationBarState createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, child) {
        return BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: widget.isRefreshing && widget.selectedIndex == 0
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                  : const Icon(Icons.home),
              label: 'bottom_navigation.home'.localized,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map),
              label: 'bottom_navigation.map'.localized,
            ),
          ],
          currentIndex: widget.selectedIndex,
          onTap: widget.onItemTapped,
        );
      },
    );
  }
}