import 'dart:math';
import 'package:calculadora_mental/features/game/domain/models.dart';
import 'package:calculadora_mental/features/game/domain/game_settings.dart';

class GameEngine {
  final GameMode mode;
  final GameSettings settings;
  final Random _rng;
  
  int current;
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

  bool check(int answer) {
    if (_last == null) return false;
    
    final isCorrect = answer == _last!.expected;
    
    if (isCorrect) {
      current = answer;
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

  int _generateOperand(Op op) {
    switch (op) {
      case Op.plus:
      case Op.minus:
        // Operandos 1-9 para suma/resta
        return _rng.nextInt(9) + 1;
        
      case Op.times:
        // Operandos 2-9 para multiplicación
        return _rng.nextInt(8) + 2;
        
      case Op.div:
        // Divisores 2-9 que dividan al valor actual
        final divisors = _divisorsOf(current);
        if (divisors.isEmpty) {
          // Si no hay divisores, fallback a suma pequeña
          return _rng.nextInt(5) + 1;
        }
        return divisors[_rng.nextInt(divisors.length)];
    }
  }

  int _apply(int value, Op op, int operand) {
    switch (op) {
      case Op.plus:
        return value + operand;
      case Op.minus:
        return value - operand;
      case Op.times:
        return value * operand;
      case Op.div:
        return value ~/ operand; // División entera
    }
  }

  List<int> _divisorsOf(int n) {
    final divisors = <int>[];
    for (int i = 2; i <= 9; i++) {
      if (n % i == 0) {
        divisors.add(i);
      }
    }
    return divisors;
  }

  bool _inRange(int value) {
    if (!settings.allowNegatives && value < 0) return false;
    return value >= settings.minResult && value <= settings.maxResult;
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

  // Obtener coste de continuar (secuencia Fibonacci por sesión)
  int getContinueCost() {
    final fibonacci = [1, 2, 3, 5, 8, 13];
    final index = continuesUsed.clamp(0, fibonacci.length - 1);
    return fibonacci[index];
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
    };
  }

  @override
  String toString() {
    return 'GameEngine(mode: $mode, current: $current, streak: $streak, continuesUsed: $continuesUsed)';
  }
}
