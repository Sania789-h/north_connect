import 'package:flutter/material.dart';

class Helpers {

  // Show Snackbar
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }

  // Navigate to new screen
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Replace screen
  static Future<T?> pushReplacement<T extends Object?>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, dynamic>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Pop screen with fallback handling
  static void pop(BuildContext context, {Widget? fallbackPage}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (fallbackPage != null) {
      pushReplacement(context, fallbackPage);
    }
  }
}