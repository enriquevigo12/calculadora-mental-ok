import 'package:flutter/foundation.dart';
import 'package:reto_matematico/features/game/domain/models.dart';

class AnalyticsService {
  static bool _isEnabled = false;

  static Future<void> initialize() async {
    // TODO: Inicializar Firebase Analytics u otro servicio
    _isEnabled = true;
    debugPrint('Analytics inicializado (stub)');
  }

  static void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (!_isEnabled) return;
    
    debugPrint('Analytics Event: $eventName ${parameters ?? {}}');
    
    // TODO: Enviar evento real a Firebase Analytics
  }

  static void logSessionStart() {
    logEvent('session_start');
  }

  static void logAnswerCorrect(GameMode mode, String operation, int timeMs) {
    logEvent('answer_correct', parameters: {
      'mode': mode.name,
      'operation': operation,
      'time_ms': timeMs,
    });
  }

  static void logAnswerIncorrect(GameMode mode, String operation, int timeMs) {
    logEvent('answer_incorrect', parameters: {
      'mode': mode.name,
      'operation': operation,
      'time_ms': timeMs,
    });
  }

  static void logStreakContinue(GameMode mode, int streak, int cost) {
    logEvent('streak_continue', parameters: {
      'mode': mode.name,
      'streak': streak,
      'cost': cost,
    });
  }

  static void logAdReward(int coins) {
    logEvent('ad_reward', parameters: {
      'coins': coins,
    });
  }

  static void logIAPPurchase(String sku, int coins) {
    logEvent('iap_purchase', parameters: {
      'sku': sku,
      'coins': coins,
    });
  }

  static void logRecordUpdated(GameMode mode, int newRecord) {
    logEvent('record_updated', parameters: {
      'mode': mode.name,
      'record': newRecord,
    });
  }

  static void logDailyBonusClaimed(int coins, int streak) {
    logEvent('daily_bonus_claimed', parameters: {
      'coins': coins,
      'streak': streak,
    });
  }

  static void logGameCompleted(GameMode mode, int finalStreak, int coinsEarned) {
    logEvent('game_completed', parameters: {
      'mode': mode.name,
      'final_streak': finalStreak,
      'coins_earned': coinsEarned,
    });
  }

  static void setUserProperty(String property, String value) {
    if (!_isEnabled) return;
    
    debugPrint('Analytics User Property: $property = $value');
    
    // TODO: Establecer propiedad real en Firebase Analytics
  }

  static void setUserId(String userId) {
    if (!_isEnabled) return;
    
    debugPrint('Analytics User ID: $userId');
    
    // TODO: Establecer ID de usuario real en Firebase Analytics
  }
}
