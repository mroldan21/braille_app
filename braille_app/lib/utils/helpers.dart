// lib/utils/helpers.dart
import 'package:flutter/material.dart';

class Helpers {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String formatDuration(int milliseconds) {
    final seconds = milliseconds / 1000;
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)}s';
    } else {
      final minutes = seconds / 60;
      return '${minutes.toStringAsFixed(1)}min';
    }
  }

  static bool isValidBrailleCharacter(String char) {
    if (char.isEmpty) return false;
    const validChars = 'abcdefghijklmnopqrstuvwxyz0123456789,.!?;:- ';
    return validChars.contains(char.toLowerCase());
  }
}