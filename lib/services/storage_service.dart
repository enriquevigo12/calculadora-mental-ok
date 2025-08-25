import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:calculadora_mental/features/game/domain/models.dart';
import 'package:calculadora_mental/features/store/domain/wallet.dart';

part 'storage_service.g.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _deviceIdKey = 'device_id';
  static const _firstLaunchKey = 'first_launch';
  
  static const _settingsBox = 'settings';
  static const _walletBox = 'wallet';
  static const _statsBox = 'stats';
  static const _purchasesBox = 'purchases';

  static Future<void> initialize() async {
    // Registrar adaptadores de Hive
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(WalletAdapter());
    Hive.registerAdapter(StatsAdapter());
    Hive.registerAdapter(PurchasesAdapter());
    
    // Abrir cajas
    await Hive.openBox<Settings>(_settingsBox);
    await Hive.openBox<Wallet>(_walletBox);
    await Hive.openBox<Stats>(_statsBox);
    await Hive.openBox<Purchases>(_purchasesBox);
  }

  // Device ID
  static Future<String> getDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  static Future<DateTime> getFirstLaunch() async {
    final timestamp = await _secureStorage.read(key: _firstLaunchKey);
    if (timestamp == null) {
      final now = DateTime.now();
      await _secureStorage.write(key: _firstLaunchKey, value: now.toIso8601String());
      return now;
    }
    return DateTime.parse(timestamp);
  }

  // Settings
  static Settings getSettings() {
    final box = Hive.box<Settings>(_settingsBox);
    return box.get('settings') ?? Settings();
  }

  static Future<void> saveSettings(Settings settings) async {
    final box = Hive.box<Settings>(_settingsBox);
    await box.put('settings', settings);
  }

  // Wallet
  static Wallet getWallet() {
    final box = Hive.box<Wallet>(_walletBox);
    return box.get('wallet') ?? Wallet();
  }

  static Future<void> saveWallet(Wallet wallet) async {
    final box = Hive.box<Wallet>(_walletBox);
    await box.put('wallet', wallet);
  }

  // Stats
  static Stats getStats() {
    final box = Hive.box<Stats>(_statsBox);
    return box.get('stats') ?? Stats();
  }

  static Future<void> saveStats(Stats stats) async {
    final box = Hive.box<Stats>(_statsBox);
    await box.put('stats', stats);
  }

  // Purchases
  static Purchases getPurchases() {
    final box = Hive.box<Purchases>(_purchasesBox);
    return box.get('purchases') ?? Purchases();
  }

  static Future<void> savePurchases(Purchases purchases) async {
    final box = Hive.box<Purchases>(_purchasesBox);
    await box.put('purchases', purchases);
  }

  // Métodos de conveniencia
  static Future<void> addCoins(int amount) async {
    final wallet = getWallet();
    wallet.coins += amount;
    await saveWallet(wallet);
  }

  static Future<void> spendCoins(int amount) async {
    final wallet = getWallet();
    if (wallet.coins >= amount) {
      wallet.coins -= amount;
      await saveWallet(wallet);
    }
  }

  static Future<void> updateBestStreak(GameMode mode, int streak) async {
    final stats = getStats();
    if (mode == GameMode.easy && streak > stats.bestStreakEasy) {
      stats.bestStreakEasy = streak;
    } else if (mode == GameMode.hard && streak > stats.bestStreakHard) {
      stats.bestStreakHard = streak;
    }
    await saveStats(stats);
  }
}

// Modelos de datos
@HiveType(typeId: 0)
class Settings extends HiveObject {
  @HiveField(0)
  int minResult = 0;
  
  @HiveField(1)
  int maxResult = 150;
  
  @HiveField(2)
  bool allowNegatives = false;
  
  @HiveField(3)
  bool allowDecimals = false;
  
  @HiveField(4)
  bool timer = false;
  
  @HiveField(5)
  bool difficultyAuto = true;
  
  @HiveField(6)
  bool sound = true;
  
  @HiveField(7)
  bool haptics = true;
  
  @HiveField(8)
  bool highContrast = false;
  
  @HiveField(9)
  bool largeText = false;

  Settings copyWith({
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
    return Settings()
      ..minResult = minResult ?? this.minResult
      ..maxResult = maxResult ?? this.maxResult
      ..allowNegatives = allowNegatives ?? this.allowNegatives
      ..allowDecimals = allowDecimals ?? this.allowDecimals
      ..timer = timer ?? this.timer
      ..difficultyAuto = difficultyAuto ?? this.difficultyAuto
      ..sound = sound ?? this.sound
      ..haptics = haptics ?? this.haptics
      ..highContrast = highContrast ?? this.highContrast
      ..largeText = largeText ?? this.largeText;
  }
}

@HiveType(typeId: 1)
class Wallet extends HiveObject {
  @HiveField(0)
  int coins = 0;
  
  @HiveField(1)
  DateTime? lastDailyBonusAt;
  
  @HiveField(2)
  DateTime? adCooldownUntil;
  
  @HiveField(3)
  int dailyBonusStreak = 0;

  int getDailyBonusAmount() {
    return 1; // Siempre 1 moneda
  }

  bool canClaimDailyBonus() {
    if (lastDailyBonusAt == null) return true;
    final now = DateTime.now();
    final lastBonus = lastDailyBonusAt!;
    return now.difference(lastBonus).inDays >= 1;
  }

  bool canWatchAd() {
    if (adCooldownUntil == null) return true;
    return DateTime.now().isAfter(adCooldownUntil!);
  }
}

@HiveType(typeId: 2)
class Stats extends HiveObject {
  @HiveField(0)
  int bestStreakEasy = 0;
  
  @HiveField(1)
  int bestStreakHard = 0;
  
  @HiveField(2)
  int totalAnswers = 0;
  
  @HiveField(3)
  int totalCorrect = 0;
  
  @HiveField(4)
  int timeTotalMs = 0;
  
  @HiveField(5)
  Map<String, int> byOperation = {};

  double get accuracyPercentage {
    if (totalAnswers == 0) return 0.0;
    return (totalCorrect / totalAnswers) * 100;
  }

  int get averageTimeMs {
    if (totalAnswers == 0) return 0;
    return timeTotalMs ~/ totalAnswers;
  }

  int getOperationCount(String operation) {
    return byOperation[operation] ?? 0;
  }

  void addOperation(String operation, bool correct, int timeMs) {
    totalAnswers++;
    if (correct) totalCorrect++;
    timeTotalMs += timeMs;
    byOperation[operation] = (byOperation[operation] ?? 0) + 1;
  }
}

@HiveType(typeId: 3)
class Purchases extends HiveObject {
  @HiveField(0)
  List<PurchaseItem> items = [];
  
  @HiveField(1)
  List<AdReward> adRewards = [];

  void addPurchase(String sku, int quantity) {
    items.add(PurchaseItem(
      sku: sku,
      quantity: quantity,
      at: DateTime.now(),
    ));
  }

  void addAdReward(int coins) {
    adRewards.add(AdReward(
      coins: coins,
      at: DateTime.now(),
    ));
  }
}

@HiveType(typeId: 4)
class PurchaseItem extends HiveObject {
  @HiveField(0)
  String sku;
  
  @HiveField(1)
  int quantity;
  
  @HiveField(2)
  DateTime at;

  PurchaseItem({
    required this.sku,
    required this.quantity,
    required this.at,
  });
}

@HiveType(typeId: 5)
class AdReward extends HiveObject {
  @HiveField(0)
  int coins;
  
  @HiveField(1)
  DateTime at;

  AdReward({
    required this.coins,
    required this.at,
  });
}

// Los adaptadores de Hive se generan automáticamente en storage_service.g.dart
