import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class Haptics {
  static Future<void> lightImpact() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> mediumImpact() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavyImpact() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.heavyImpact();
    }
  }

  static Future<void> selectionClick() async {
    if (await Vibration.hasVibrator() ?? false) {
      HapticFeedback.selectionClick();
    }
  }

  static Future<void> success() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  static Future<void> error() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 100, 50, 100]);
    }
  }

  static Future<void> record() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
    }
  }
}
