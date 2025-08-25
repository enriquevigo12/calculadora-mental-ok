import 'package:calculadora_mental/features/game/domain/models.dart';
import 'package:calculadora_mental/features/game/domain/game_engine.dart';
import 'package:calculadora_mental/features/game/domain/game_settings.dart';
import 'package:calculadora_mental/services/storage_service.dart';
import 'package:calculadora_mental/services/analytics_service.dart';

class SessionRepository {
  GameSession? _currentSession;
  GameEngine? _engine;
  DateTime? _lastAnswerTime;

  GameSession? get currentSession => _currentSession;
  GameEngine? get engine => _engine;

  void startSession(GameMode mode, GameSettings settings, {int? seed}) {
    _engine = GameEngine(
      mode: mode,
      settings: settings,
      seed: seed,
    );
    
    _engine!.start();
    
    _currentSession = GameSession(
      mode: mode,
      seed: seed ?? DateTime.now().millisecondsSinceEpoch,
      startedAt: DateTime.now(),
    );
    
    _lastAnswerTime = DateTime.now();
    
    AnalyticsService.logSessionStart();
  }

  StepOp getNextOperation() {
    if (_engine == null) {
      throw StateError('Sesión no iniciada');
    }
    
    return _engine!.nextValidOp();
  }

  bool submitAnswer(int answer) {
    if (_engine == null || _currentSession == null) {
      throw StateError('Sesión no iniciada');
    }
    
    final now = DateTime.now();
    final timeMs = _lastAnswerTime != null 
        ? now.difference(_lastAnswerTime!).inMilliseconds 
        : 0;
    
    final isCorrect = _engine!.check(answer);
    final operation = _engine!.lastOperation;
    
    // Actualizar sesión
    _currentSession!.addAnswer(isCorrect, timeMs);
    _currentSession!.streak = _engine!.streak;
    
    // Actualizar estadísticas
    _updateStats(isCorrect, operation, timeMs);
    
    // Analytics
    if (isCorrect) {
      AnalyticsService.logAnswerCorrect(
        _currentSession!.mode,
        operation?.operationKey ?? 'unknown',
        timeMs,
      );
    } else {
      AnalyticsService.logAnswerIncorrect(
        _currentSession!.mode,
        operation?.operationKey ?? 'unknown',
        timeMs,
      );
    }
    
    _lastAnswerTime = now;
    
    return isCorrect;
  }

  void _updateStats(bool isCorrect, StepOp? operation, int timeMs) {
    if (operation == null) return;
    
    final stats = StorageService.getStats();
    stats.addOperation(operation.operationKey, isCorrect, timeMs);
    StorageService.saveStats(stats);
  }

  Future<void> endSession() async {
    if (_currentSession == null) return;
    
    // Calcular monedas ganadas
    final coinsEarned = _calculateCoinsEarned();
    _currentSession!.coinsEarned = coinsEarned;
    
    // Añadir monedas al wallet
    await StorageService.addCoins(coinsEarned);
    
    // Actualizar récords
    await _updateRecords();
    
    // Analytics
    AnalyticsService.logGameCompleted(
      _currentSession!.mode,
      _currentSession!.streak,
      coinsEarned,
    );
    
    // Limpiar sesión
    _currentSession = null;
    _engine = null;
    _lastAnswerTime = null;
  }

  int _calculateCoinsEarned() {
    if (_currentSession == null) return 0;
    
    int coins = 0;
    
    // +1 moneda cada 10 aciertos
    coins += (_currentSession!.correctAnswers ~/ 10);
    
    return coins;
  }

  Future<void> _updateRecords() async {
    if (_currentSession == null) return;
    
    final stats = StorageService.getStats();
    bool newRecord = false;
    
    if (_currentSession!.mode == GameMode.easy) {
      if (_currentSession!.streak > stats.bestStreakEasy) {
        stats.bestStreakEasy = _currentSession!.streak;
        newRecord = true;
      }
    } else {
      if (_currentSession!.streak > stats.bestStreakHard) {
        stats.bestStreakHard = _currentSession!.streak;
        newRecord = true;
      }
    }
    
    await StorageService.saveStats(stats);
    
    if (newRecord) {
      AnalyticsService.logRecordUpdated(
        _currentSession!.mode,
        _currentSession!.streak,
      );
    }
  }

  bool canContinue() {
    if (_engine == null) return false;
    return _engine!.canContinue();
  }

  int getContinueCost() {
    if (_engine == null) return 0;
    return _engine!.getContinueCost();
  }

  Future<bool> continueSession() async {
    if (!canContinue()) return false;
    
    final cost = getContinueCost();
    final wallet = StorageService.getWallet();
    
    if (wallet.coins < cost) return false;
    
    // Gastar monedas
    await StorageService.spendCoins(cost);
    
    // Usar continuación
    _engine!.useContinue();
    _currentSession!.continuesUsed = _engine!.continuesUsed;
    
    // Analytics
    AnalyticsService.logStreakContinue(
      _currentSession!.mode,
      _currentSession!.streak,
      cost,
    );
    
    return true;
  }

  Map<String, dynamic> getSessionState() {
    if (_currentSession == null) return {};
    
    return {
      'mode': _currentSession!.mode.name,
      'streak': _currentSession!.streak,
      'continuesUsed': _currentSession!.continuesUsed,
      'coinsEarned': _currentSession!.coinsEarned,
      'totalAnswers': _currentSession!.totalAnswers,
      'correctAnswers': _currentSession!.correctAnswers,
      'accuracy': _currentSession!.accuracyPercentage,
      'averageTime': _currentSession!.averageTimeMs,
    };
  }

  void dispose() {
    _currentSession = null;
    _engine = null;
    _lastAnswerTime = null;
  }
}
