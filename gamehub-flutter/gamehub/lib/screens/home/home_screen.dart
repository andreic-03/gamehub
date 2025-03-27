import 'package:flutter/material.dart';

import '../base_screen.dart';
import '../game_post/create_game_post_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGamePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}