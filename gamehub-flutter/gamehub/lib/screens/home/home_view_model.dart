import 'package:flutter/material.dart';

import '../base_screen.dart';
import '../game_post/create_game_post_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<BaseScreenState> _baseScreenKey = GlobalKey<BaseScreenState>();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      key: _baseScreenKey,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGamePostScreen(),
            ),
          );
          // If a game post was successfully created, refresh the home data
          if (result == true && _baseScreenKey.currentState != null) {
            await _baseScreenKey.currentState!.refreshHomeContent();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}