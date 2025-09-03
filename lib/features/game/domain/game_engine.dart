import 'dart:math';
import 'package:calculadora_mental/features/game/domain/models.dart';
import 'package:calculadora_mental/features/game/domain/game_settings.dart';

class GameEngine {
  final GameMode mode;
  final GameSettings settings;
  final Random _rng;
  
  dynamic current; // Cambiar a dynamic para soportar decimales
  int streak;
  int continuesUsed;
  StepOp? _last;
  int _difficultyLevel;

  StepOp? get lastOperation => _last;

  GameEngine({
    required this.mode,
    required this.settings,
    int? seed,
  }) : _rng = Random(seed),
       current = 0,
       streak = 0,
       continuesUsed = 0,
       _difficultyLevel = 1;

  void start() {
    // Valor inicial aleatorio entre 5 y 20
    current = _rng.nextInt(16) + 5;
    streak = 0;
    continuesUsed = 0;
    _last = null;
    _difficultyLevel = 1;
  }

  StepOp nextOp() {
    _last = _generateValidOp();
    return _last!;
  }

  bool check(dynamic answer) {
    if (_last == null) return false;
    
    bool isCorrect;
    
    if (_allowDecimalsInMode) {
      // En modo fácil con decimales, permitir respuestas decimales
      if (answer is double) {
        isCorrect = (answer - _last!.expected).abs() < 0.01; // Tolerancia de 0.01
      } else if (answer is int) {
        isCorrect = answer == _last!.expected;
      } else {
        isCorrect = false;
      }
    } else {
      // En modo difícil o sin decimales, solo enteros
      if (answer is int) {
        isCorrect = answer == _last!.expected;
      } else {
        isCorrect = false;
      }
    }
    
    if (isCorrect) {
      current = _last!.expected; // Mantener el valor esperado
      streak++;
      
      // Ajustar dificultad dinámica
      if (settings.difficultyAuto && streak % 5 == 0) {
        _difficultyLevel++;
      }
    }
    
    return isCorrect;
  }

  Op _weightedOp() {
    if (mode == GameMode.easy) {
      // Solo suma y resta para modo fácil
      return _rng.nextBool() ? Op.plus : Op.minus;
    } else {
      // Modo difícil: pesos por defecto +25%, -25%, ×30%, ÷20%
      final weights = [25, 25, 30, 20];
      final total = weights.reduce((a, b) => a + b);
      final random = _rng.nextInt(total);
      
      int cumulative = 0;
      for (int i = 0; i < weights.length; i++) {
        cumulative += weights[i];
        if (random < cumulative) {
          return Op.values[i];
        }
      }
      return Op.plus; // Fallback
    }
  }

  dynamic _generateOperand(Op op) {
    switch (op) {
      case Op.plus:
      case Op.minus:
        if (_allowDecimalsInMode) {
          // En modo fácil con decimales, generar operandos decimales (0.1 a 2.0)
          return (_rng.nextInt(20) + 1) / 10.0; // 0.1, 0.2, ..., 2.0
        } else {
          // Operandos 1-9 para suma/resta
          return _rng.nextInt(9) + 1;
        }
        
      case Op.times:
        // Operandos 2-9 para multiplicación (siempre enteros)
        return _rng.nextInt(8) + 2;
        
      case Op.div:
        // Divisores 2-9 que dividan al valor actual (siempre enteros)
        final divisors = _divisorsOf(current);
        if (divisors.isEmpty) {
          // Si no hay divisores, fallback a suma pequeña
          return _rng.nextInt(5) + 1;
        }
        return divisors[_rng.nextInt(divisors.length)];
    }
  }

  dynamic _apply(dynamic value, Op op, dynamic operand) {
    switch (op) {
      case Op.plus:
        return value + operand;
      case Op.minus:
        return value - operand;
      case Op.times:
        return value * operand;
      case Op.div:
        if (value is int && operand is int) {
          return value ~/ operand; // División entera
        } else {
          return value / operand; // División con decimales
        }
    }
  }

  List<int> _divisorsOf(dynamic n) {
    final divisors = <int>[];
    final intValue = n is int ? n : n.round();
    for (int i = 2; i <= 9; i++) {
      if (intValue % i == 0) {
        divisors.add(i);
      }
    }
    return divisors;
  }

  bool _inRange(dynamic value) {
    if (!settings.allowNegatives && value < 0) return false;
    return value >= settings.minResult && value <= settings.maxResult;
  }

  // Verificar si se permiten decimales según el modo
  bool get _allowDecimalsInMode {
    // Solo permitir decimales en modo fácil
    return mode == GameMode.easy && settings.allowDecimals;
  }

  StepOp _generateValidOp() {
    // Intentar generar una operación válida hasta 20 veces
    for (int attempts = 0; attempts < 20; attempts++) {
      final op = _weightedOp();
      final operand = _generateOperand(op);
      final result = _apply(current, op, operand);
      
      if (_inRange(result)) {
        return StepOp(
          op: op,
          operand: operand,
          expected: result, // Este es el valor acumulado después de la operación
        );
      }
    }
    
    // Si no se encuentra una operación válida, reroll del valor actual
    current = _rng.nextInt(16) + 5;
    return _generateValidOp();
  }

  // Método público para generar la siguiente operación válida
  StepOp nextValidOp() {
    return nextOp();
  }

  // Ajustar dificultad basada en errores recientes
  void adjustDifficulty(bool recentErrors) {
    if (!settings.difficultyAuto) return;
    
    if (recentErrors && _difficultyLevel > 1) {
      _difficultyLevel--;
    }
  }

  // Obtener coste de continuar (secuencia personalizada: 1, 3, 7)
  int getContinueCost() {
    final costs = [1, 3, 7];
    final index = continuesUsed.clamp(0, costs.length - 1);
    return costs[index];
  }

  // Verificar si se puede continuar
  bool canContinue() {
    return continuesUsed < 3; // Máximo 3 continuaciones por sesión
  }

  // Usar una continuación
  void useContinue() {
    if (canContinue()) {
      continuesUsed++;
    }
  }

  // Obtener información del estado actual
  Map<String, dynamic> getState() {
    return {
      'current': current,
      'streak': streak,
      'continuesUsed': continuesUsed,
      'difficultyLevel': _difficultyLevel,
      'mode': mode.name,
      'allowDecimals': _allowDecimalsInMode,
    };
  }

  @override
  String toString() {
    return 'GameEngine(mode: $mode, current: $current, streak: $streak, continuesUsed: $continuesUsed, allowDecimals: $_allowDecimalsInMode)';
  }
}
