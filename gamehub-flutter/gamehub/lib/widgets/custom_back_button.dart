import 'package:flutter/material.dart';

/// A reusable custom back button widget that follows Flutter best practices.
/// 
/// This widget provides a consistent back button implementation across the app
/// with a fixed position in the top-left corner.
/// 
/// Example usage:
/// ```dart
/// Stack(
///   children: [
///     YourContentWidget(),
///     CustomBackButton(),
///   ],
/// )
/// ```
class CustomBackButton extends StatelessWidget {
  /// Optional callback when the button is pressed.
  /// If not provided, will use Navigator.of(context).pop()
  final VoidCallback? onPressed;
  
  /// Optional hero tag to differentiate multiple instances
  /// The default uses a unique tag
  final String? heroTag;

  const CustomBackButton({
    Key? key,
    this.onPressed,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      child: FloatingActionButton.small(
        heroTag: heroTag ?? "default_back_button",
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
