import 'dart:math';
import 'package:reto_matematico/features/game/domain/models.dart';

class DailyChallengeService {
  static final DailyChallengeService _instance = DailyChallengeService._internal();
  factory DailyChallengeService() => _instance;
  DailyChallengeService._internal();

  // Generar un reto diario único basado en la fecha
  DailyChallenge generateDailyChallenge(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    
    return DailyChallenge(
      id: 'challenge_${date.toIso8601String().split('T')[0]}',
      date: date,
      phases: [
        _generatePhase1(random),
        _generatePhase2(random),
        _generatePhase3(random),
      ],
    );
  }

  // Fase 1: Número oculto sencillo
  ChallengePhase _generatePhase1(Random random) {
    final num1 = random.nextInt(20) + 1;
    final num2 = random.nextInt(15) + 1;
    final result = num1 + num2;
    
    return ChallengePhase(
      phaseNumber: 1,
      equation: '__ + $num2 = $result',
      placeholders: ['__'],
      correctAnswers: [num1],
      hints: [
        'El número es mayor que ${(num1 * 0.7).round()}',
        'El número es menor que ${(num1 * 1.3).round()}',
        'El número está entre ${(num1 - 2).clamp(1, 50)} y ${(num1 + 2).clamp(1, 50)}',
      ],
    );
  }

  // Fase 2: Ecuación con varios huecos
  ChallengePhase _generatePhase2(Random random) {
    final num1 = random.nextInt(10) + 1;
    final num2 = random.nextInt(10) + 1;
    final result = num1 * 3 - num2;
    
    return ChallengePhase(
      phaseNumber: 2,
      equation: '__ × 3 - __ = $result',
      placeholders: ['__', '__'],
      correctAnswers: [num1, num2],
      hints: [
        'El primer número está entre 1 y 10',
        'El segundo número está entre 1 y 10',
        'El primer número multiplicado por 3 es mayor que $result',
      ],
    );
  }

  // Fase 3: Operación larga tipo puzzle
  ChallengePhase _generatePhase3(Random random) {
    final num1 = random.nextInt(5) + 1;
    final num2 = random.nextInt(5) + 1;
    final num3 = random.nextInt(5) + 1;
    final num4 = random.nextInt(5) + 1;
    final result = 5 + 3 * 2 - 4 ~/ 2 + num1;
    
    return ChallengePhase(
      phaseNumber: 3,
      equation: '5 + 3 × 2 - 4 ÷ 2 + __ = $result',
      placeholders: ['__'],
      correctAnswers: [num1],
      hints: [
        'El número es mayor que 0',
        'El número es menor que 10',
        'El número es par' + (num1 % 2 == 0 ? ' (correcto)' : ' (incorrecto)'),
      ],
    );
  }

  // Verificar si una respuesta es correcta para una fase
  bool checkAnswer(ChallengePhase phase, List<num> answers) {
    if (answers.length != phase.correctAnswers.length) return false;
    
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] != phase.correctAnswers[i]) return false;
    }
    return true;
  }

  // Obtener una pista aleatoria para una fase
  String getRandomHint(ChallengePhase phase) {
    final random = Random();
    return phase.hints[random.nextInt(phase.hints.length)];
  }

  // Verificar si se puede jugar el reto del día
  bool canPlayDailyChallenge(DateTime lastPlayedDate, DateTime currentDate) {
    final lastPlayed = DateTime(lastPlayedDate.year, lastPlayedDate.month, lastPlayedDate.day);
    final current = DateTime(currentDate.year, currentDate.month, currentDate.day);
    
    return lastPlayed.isBefore(current);
  }

  // Calcular la nueva racha
  int calculateNewStreak(int currentStreak, DateTime lastCompletedDate, DateTime currentDate) {
    final lastCompleted = DateTime(lastCompletedDate.year, lastCompletedDate.month, lastCompletedDate.day);
    final current = DateTime(currentDate.year, currentDate.month, currentDate.day);
    
    final difference = current.difference(lastCompleted).inDays;
    
    if (difference == 1) {
      return currentStreak + 1;
    } else if (difference > 1) {
      return 1; // Nueva racha
    } else {
      return currentStreak; // Mismo día
    }
  }
}
