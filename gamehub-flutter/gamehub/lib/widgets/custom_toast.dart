import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  static void showText(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    double bottomOffset = 96,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
  }) {
    final fToast = FToast();
    fToast.init(context);
    fToast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
      positionedToastBuilder: (ctx, child, gravity) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: bottomOffset,
          child: Center(child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


