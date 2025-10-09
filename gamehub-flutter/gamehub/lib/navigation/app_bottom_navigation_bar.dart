import 'package:flutter/material.dart';
import '../localization/localized_text.dart';
import '../localization/localization_service.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const AppBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
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
              icon: const Icon(Icons.home),
              label: 'bottom_navigation.home'.localized,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map),
              label: 'bottom_navigation.map'.localized,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'bottom_navigation.profile'.localized,
            ),
          ],
          currentIndex: widget.selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: widget.onItemTapped,
        );
      },
    );
  }
}