import 'package:flutter/material.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/profile_picture.png'),
          ),
          const SizedBox(height: 20),
          const Text('John Doe'),
          const Text('Level: 42'),
          ElevatedButton(
            onPressed: () {
              // Add functionality for profile screen
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}