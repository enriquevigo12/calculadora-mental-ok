import 'package:calculadora_mental/services/storage_service.dart';

class GameSettings {
  final int minResult;
  final int maxResult;
  final bool allowNegatives;
  final bool allowDecimals;
  final bool timer;
  final bool difficultyAuto;
  final bool sound;
  final bool haptics;
  final bool highContrast;
  final bool largeText;

  const GameSettings({
    this.minResult = 0,
    this.maxResult = 150,
    this.allowNegatives = false,
    this.allowDecimals = false,
    this.timer = false,
    this.difficultyAuto = true,
    this.sound = true,
    this.haptics = true,
    this.highContrast = false,
    this.largeText = false,
  });

  GameSettings copyWith({
    int? minResult,
    int? maxResult,
    bool? allowNegatives,
    bool? allowDecimals,
    bool? timer,
    bool? difficultyAuto,
    bool? sound,
    bool? haptics,
    bool? highContrast,
    bool? largeText,
  }) {
    return GameSettings(
      minResult: minResult ?? this.minResult,
      maxResult: maxResult ?? this.maxResult,
      allowNegatives: allowNegatives ?? this.allowNegatives,
      allowDecimals: allowDecimals ?? this.allowDecimals,
      timer: timer ?? this.timer,
      difficultyAuto: difficultyAuto ?? this.difficultyAuto,
      sound: sound ?? this.sound,
      haptics: haptics ?? this.haptics,
      highContrast: highContrast ?? this.highContrast,
      largeText: largeText ?? this.largeText,
    );
  }

  static GameSettings fromStorage() {
    final storageSettings = StorageService.getSettings();
    return GameSettings(
      minResult: storageSettings.minResult,
      maxResult: storageSettings.maxResult,
      allowNegatives: storageSettings.allowNegatives,
      allowDecimals: storageSettings.allowDecimals,
      timer: storageSettings.timer,
      difficultyAuto: storageSettings.difficultyAuto,
      sound: storageSettings.sound,
      haptics: storageSettings.haptics,
      highContrast: storageSettings.highContrast,
      largeText: storageSettings.largeText,
    );
  }

  Future<void> saveToStorage() async {
    final storageSettings = Settings()
      ..minResult = minResult
      ..maxResult = maxResult
      ..allowNegatives = allowNegatives
      ..allowDecimals = allowDecimals
      ..timer = timer
      ..difficultyAuto = difficultyAuto
      ..sound = sound
      ..haptics = haptics
      ..highContrast = highContrast
      ..largeText = largeText;
    
    await StorageService.saveSettings(storageSettings);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameSettings &&
        other.minResult == minResult &&
        other.maxResult == maxResult &&
        other.allowNegatives == allowNegatives &&
        other.allowDecimals == allowDecimals &&
        other.timer == timer &&
        other.difficultyAuto == difficultyAuto &&
        other.sound == sound &&
        other.haptics == haptics &&
        other.highContrast == highContrast &&
        other.largeText == largeText;
  }

  @override
  int get hashCode {
    return Object.hash(
      minResult,
      maxResult,
      allowNegatives,
      allowDecimals,
      timer,
      difficultyAuto,
      sound,
      haptics,
      highContrast,
      largeText,
    );
  }

  @override
  String toString() {
    return 'GameSettings(minResult: $minResult, maxResult: $maxResult, allowNegatives: $allowNegatives, allowDecimals: $allowDecimals, timer: $timer, difficultyAuto: $difficultyAuto, sound: $sound, haptics: $haptics, highContrast: $highContrast, largeText: $largeText)';
  }
}
