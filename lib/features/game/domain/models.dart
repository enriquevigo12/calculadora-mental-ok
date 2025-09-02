enum GameMode { easy, hard }

enum Op { plus, minus, times, div }

class StepOp {
  final Op op;
  final dynamic operand; // Cambiar a dynamic para soportar decimales
  final dynamic expected; // Cambiar a dynamic para soportar decimales

  const StepOp({
    required this.op,
    required this.operand,
    required this.expected,
  });

  String get displayText {
    final operandText = operand is double ? operand.toStringAsFixed(1) : operand.toString();
    switch (op) {
      case Op.plus:
        return '+ $operandText';
      case Op.minus:
        return '- $operandText';
      case Op.times:
        return '× $operandText';
      case Op.div:
        return '÷ $operandText';
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

// Modelo para el reto del día
class DailyChallenge {
  final String id;
  final DateTime date;
  final List<ChallengePhase> phases;
  final bool isCompleted;
  final int currentPhase;
  final int attempts;
  final int hintsUsed;
  final int coinsSpent;

  DailyChallenge({
    required this.id,
    required this.date,
    required this.phases,
    this.isCompleted = false,
    this.currentPhase = 0,
    this.attempts = 0,
    this.hintsUsed = 0,
    this.coinsSpent = 0,
  });

  DailyChallenge copyWith({
    String? id,
    DateTime? date,
    List<ChallengePhase>? phases,
    bool? isCompleted,
    int? currentPhase,
    int? attempts,
    int? hintsUsed,
    int? coinsSpent,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      date: date ?? this.date,
      phases: phases ?? this.phases,
      isCompleted: isCompleted ?? this.isCompleted,
      currentPhase: currentPhase ?? this.currentPhase,
      attempts: attempts ?? this.attempts,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      coinsSpent: coinsSpent ?? this.coinsSpent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'phases': phases.map((phase) => phase.toJson()).toList(),
      'isCompleted': isCompleted,
      'currentPhase': currentPhase,
      'attempts': attempts,
      'hintsUsed': hintsUsed,
      'coinsSpent': coinsSpent,
    };
  }

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'],
      date: DateTime.parse(json['date']),
      phases: (json['phases'] as List).map((phase) => ChallengePhase.fromJson(phase)).toList(),
      isCompleted: json['isCompleted'] ?? false,
      currentPhase: json['currentPhase'] ?? 0,
      attempts: json['attempts'] ?? 0,
      hintsUsed: json['hintsUsed'] ?? 0,
      coinsSpent: json['coinsSpent'] ?? 0,
    );
  }
}

// Modelo para cada fase del reto
class ChallengePhase {
  final int phaseNumber;
  final String equation;
  final List<String> placeholders;
  final List<num> correctAnswers;
  final List<String> hints;
  final bool isCompleted;
  final int attempts;

  ChallengePhase({
    required this.phaseNumber,
    required this.equation,
    required this.placeholders,
    required this.correctAnswers,
    required this.hints,
    this.isCompleted = false,
    this.attempts = 0,
  });

  ChallengePhase copyWith({
    int? phaseNumber,
    String? equation,
    List<String>? placeholders,
    List<num>? correctAnswers,
    List<String>? hints,
    bool? isCompleted,
    int? attempts,
  }) {
    return ChallengePhase(
      phaseNumber: phaseNumber ?? this.phaseNumber,
      equation: equation ?? this.equation,
      placeholders: placeholders ?? this.placeholders,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      hints: hints ?? this.hints,
      isCompleted: isCompleted ?? this.isCompleted,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phaseNumber': phaseNumber,
      'equation': equation,
      'placeholders': placeholders,
      'correctAnswers': correctAnswers,
      'hints': hints,
      'isCompleted': isCompleted,
      'attempts': attempts,
    };
  }

  factory ChallengePhase.fromJson(Map<String, dynamic> json) {
    return ChallengePhase(
      phaseNumber: json['phaseNumber'],
      equation: json['equation'],
      placeholders: List<String>.from(json['placeholders']),
      correctAnswers: List<num>.from(json['correctAnswers']),
      hints: List<String>.from(json['hints']),
      isCompleted: json['isCompleted'] ?? false,
      attempts: json['attempts'] ?? 0,
    );
  }
}

// Modelo para las estadísticas del reto diario
class DailyChallengeStats {
  final int currentStreak;
  final int bestStreak;
  final int totalCompleted;
  final int totalCoinsEarned;
  final DateTime lastCompletedDate;

  DailyChallengeStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCompleted,
    required this.totalCoinsEarned,
    required this.lastCompletedDate,
  });

  DailyChallengeStats copyWith({
    int? currentStreak,
    int? bestStreak,
    int? totalCompleted,
    int? totalCoinsEarned,
    DateTime? lastCompletedDate,
  }) {
    return DailyChallengeStats(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalCompleted': totalCompleted,
      'totalCoinsEarned': totalCoinsEarned,
      'lastCompletedDate': lastCompletedDate.toIso8601String(),
    };
  }

  factory DailyChallengeStats.fromJson(Map<String, dynamic> json) {
    return DailyChallengeStats(
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      totalCompleted: json['totalCompleted'] ?? 0,
      totalCoinsEarned: json['totalCoinsEarned'] ?? 0,
      lastCompletedDate: DateTime.parse(json['lastCompletedDate']),
    );
  }
}
