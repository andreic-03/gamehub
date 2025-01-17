import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String firstName;
  final double radius;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.firstName,
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.amber,
          width: 3,
        ),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: Colors.grey[300],
      )
          : CircleAvatar(
        radius: radius,
        backgroundColor: Colors.green,
        child: Text(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 1.3,
          ),
        ),
      ),
    );
  }
}