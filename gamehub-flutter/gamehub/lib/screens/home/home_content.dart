import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome to GameHub'),
          ElevatedButton(
            onPressed: () {
              // Add functionality for home screen
            },
            child: const Text('Start Gaming'),
          ),
        ],
      ),
    );
  }
}