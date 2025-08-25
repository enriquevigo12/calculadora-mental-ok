enum GameMode { easy, hard }

enum Op { plus, minus, times, div }

class StepOp {
  final Op op;
  final int operand;
  final int expected;

  const StepOp({
    required this.op,
    required this.operand,
    required this.expected,
  });

  String get displayText {
    switch (op) {
      case Op.plus:
        return '+ $operand';
      case Op.minus:
        return '- $operand';
      case Op.times:
        return '× $operand';
      case Op.div:
        return '÷ $operand';
    }
  }

  String get operationKey {
    switch (op) {
      case Op.plus:
        return 'plus';
      case Op.minus:
        return 'minus';
      case Op.times:
        return 'times';
      case Op.div:
        return 'div';
    }
  }

  @override
  String toString() {
    return 'StepOp(op: $op, operand: $operand, expected: $expected)';
  }
}

class GameSession {
  final GameMode mode;
  final int seed;
  final DateTime startedAt;
  int streak;
  int continuesUsed;
  int coinsEarned;
  int totalAnswers;
  int correctAnswers;
  int totalTimeMs;

  GameSession({
    required this.mode,
    required this.seed,
    required this.startedAt,
    this.streak = 0,
    this.continuesUsed = 0,
    this.coinsEarned = 0,
    this.totalAnswers = 0,
    this.correctAnswers = 0,
    this.totalTimeMs = 0,
  });

  double get accuracyPercentage {
    if (totalAnswers == 0) return 0.0;
    return (correctAnswers / totalAnswers) * 100;
  }

  int get averageTimeMs {
    if (totalAnswers == 0) return 0;
    return totalTimeMs ~/ totalAnswers;
  }

  void addAnswer(bool correct, int timeMs) {
    totalAnswers++;
    if (correct) correctAnswers++;
    totalTimeMs += timeMs;
  }

  void addCoins(int amount) {
    coinsEarned += amount;
  }

  void useContinue() {
    continuesUsed++;
  }

  @override
  String toString() {
    return 'GameSession(mode: $mode, streak: $streak, continuesUsed: $continuesUsed, coinsEarned: $coinsEarned)';
  }
}
