import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:calculadora_mental/features/game/domain/models.dart';
import 'package:calculadora_mental/services/daily_challenge_service.dart';
import 'package:calculadora_mental/services/storage_service.dart';
import 'package:calculadora_mental/theme/app_theme.dart';
import 'package:calculadora_mental/shared/widgets/number_keypad.dart';
import 'package:calculadora_mental/shared/utils/haptics.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  DailyChallenge? _challenge; // Cambiar a nullable
  late DailyChallengeService _challengeService;
  late ConfettiController _confettiController;
  
  List<num> _currentAnswers = [];
  int _currentAnswerIndex = 0;
  bool _showHint = false;
  String _currentHint = '';
  bool _isPhaseCompleted = false;
  bool _showPhaseComplete = false;
  bool _isLoading = true; // Agregar flag de carga

  @override
  void initState() {
    super.initState();
    _challengeService = DailyChallengeService();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Generar o cargar el reto del día
    _loadDailyChallenge();
  }

  void _loadDailyChallenge() async {
    try {
      final today = DateTime.now();
      final stats = await StorageService.getDailyChallengeStats();
      
      // Verificar si ya se completó hoy
      if (stats.lastCompletedDate.year == today.year &&
          stats.lastCompletedDate.month == today.month &&
          stats.lastCompletedDate.day == today.day) {
        // Ya se completó hoy
        if (mounted) {
          _showAlreadyCompletedDialog();
        }
        return;
      }
      
      // Generar nuevo reto
      final challenge = _challengeService.generateDailyChallenge(today);
      
      if (mounted) {
        setState(() {
          _challenge = challenge;
          _isLoading = false;
        });
        _resetPhase();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el reto: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _resetPhase() {
    final currentPhase = _challenge!.phases[_challenge!.currentPhase];
    _currentAnswers = List.filled(currentPhase.placeholders.length, 0);
    _currentAnswerIndex = 0;
    _showHint = false;
    _currentHint = '';
    _isPhaseCompleted = false;
    _showPhaseComplete = false;
  }

  void _onNumberPressed(String number) {
    if (_isPhaseCompleted) return;
    
    setState(() {
      if (_currentAnswerIndex < _currentAnswers.length) {
        _currentAnswers[_currentAnswerIndex] = int.parse(number);
        _currentAnswerIndex++;
      }
    });
    
    Haptics.lightImpact();
  }

  void _onBackspace() {
    if (_currentAnswerIndex > 0) {
      setState(() {
        _currentAnswerIndex--;
        _currentAnswers[_currentAnswerIndex] = 0;
      });
    }
    Haptics.lightImpact();
  }

  void _onConfirm() {
    if (_currentAnswerIndex < _challenge!.phases[_challenge!.currentPhase].placeholders.length) {
      // Aún faltan números por ingresar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los números antes de confirmar'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final currentPhase = _challenge!.phases[_challenge!.currentPhase];
    final isCorrect = _challengeService.checkAnswer(currentPhase, _currentAnswers);

    if (isCorrect) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
  }

  void _handleCorrectAnswer() {
    final currentPhase = _challenge!.phases[_challenge!.currentPhase];
    
    setState(() {
      _isPhaseCompleted = true;
      _showPhaseComplete = true;
    });

    Haptics.success();
    
    // Marcar fase como completada
    _challenge = _challenge!.copyWith(
      phases: _challenge!.phases.map((phase) {
        if (phase.phaseNumber == currentPhase.phaseNumber) {
          return phase.copyWith(isCompleted: true);
        }
        return phase;
      }).toList(),
    );

    // Verificar si se completó todo el reto
    if (_challenge!.phases.every((phase) => phase.isCompleted)) {
      _handleChallengeCompleted();
    } else {
      // Mostrar mensaje de fase completada
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showPhaseComplete = false;
          });
          _nextPhase();
        }
      });
    }
  }

  void _handleIncorrectAnswer() {
    Haptics.error();
    
    // Incrementar intentos
    final currentPhase = _challenge!.phases[_challenge!.currentPhase];
    _challenge = _challenge!.copyWith(
      phases: _challenge!.phases.map((phase) {
        if (phase.phaseNumber == currentPhase.phaseNumber) {
          return phase.copyWith(attempts: phase.attempts + 1);
        }
        return phase;
      }).toList(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Respuesta incorrecta. ¡Inténtalo de nuevo!'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _nextPhase() {
    if (_challenge!.currentPhase < _challenge!.phases.length - 1) {
      setState(() {
        _challenge = _challenge!.copyWith(
          currentPhase: _challenge!.currentPhase + 1,
        );
      });
      _resetPhase();
    }
  }

  void _handleChallengeCompleted() async {
    // Mostrar confetti
    _confettiController.play();
    
    // Actualizar estadísticas
    final stats = await StorageService.getDailyChallengeStats();
    final newStreak = _challengeService.calculateNewStreak(
      stats.currentStreak,
      stats.lastCompletedDate,
      DateTime.now(),
    );
    
    final newStats = stats.copyWith(
      currentStreak: newStreak,
      bestStreak: newStreak > stats.bestStreak ? newStreak : stats.bestStreak,
      totalCompleted: stats.totalCompleted + 1,
      totalCoinsEarned: stats.totalCoinsEarned + 5,
      lastCompletedDate: DateTime.now(),
    );
    
    await StorageService.saveDailyChallengeStats(newStats);
    
    // Dar monedas
    final wallet = StorageService.getWallet();
    StorageService.saveWallet(wallet.copyWith(coins: wallet.coins + 5));
    
    // Mostrar diálogo de éxito
    _showChallengeCompletedDialog();
  }

  void _buyHint() async {
    final wallet = StorageService.getWallet();
    if (wallet.coins < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes suficientes monedas para comprar una pista'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Comprar pista
    StorageService.saveWallet(wallet.copyWith(coins: wallet.coins - 5));
    
    final currentPhase = _challenge!.phases[_challenge!.currentPhase];
    final hint = _challengeService.getRandomHint(currentPhase);
    
    setState(() {
      _showHint = true;
      _currentHint = hint;
    });

    Haptics.lightImpact();
  }

  void _retryPhase() async {
    final wallet = StorageService.getWallet();
    if (wallet.coins < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes suficientes monedas para reintentar'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Pagar por reintentar
    StorageService.saveWallet(wallet.copyWith(coins: wallet.coins - 5));
    
    setState(() {
      _challenge = _challenge!.copyWith(
        coinsSpent: _challenge!.coinsSpent + 5,
      );
    });
    
    _resetPhase();
    Haptics.lightImpact();
  }

  void _showAlreadyCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Reto Completado! 🎉'),
        content: const Text('Ya has completado el reto del día. ¡Vuelve mañana para un nuevo desafío!'),
        actions: [
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Volver al Inicio'),
          ),
        ],
      ),
    );
  }

  void _showChallengeCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Reto Completado! 🔥'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¡Has completado el reto del día!'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: AppColors.accentWarm),
                const SizedBox(width: 8),
                Text('+1 en racha diaria'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: AppColors.coinColor),
                const SizedBox(width: 8),
                Text('+5 monedas'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detectar tamaño de pantalla para hacer todo responsive
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;
    final isWideScreen = screenWidth > 400;
    
    // Calcular tamaños responsivos
    final headerHeight = isVerySmallScreen ? 80.0 : (isSmallScreen ? 90.0 : 100.0);
    final progressHeight = isVerySmallScreen ? 6.0 : (isSmallScreen ? 8.0 : 10.0);
    final phaseTitleSize = isVerySmallScreen ? 20.0 : (isSmallScreen ? 24.0 : 28.0);
    final equationSize = isVerySmallScreen ? 24.0 : (isSmallScreen ? 28.0 : 32.0);
    final inputBoxSize = isVerySmallScreen ? 40.0 : (isSmallScreen ? 45.0 : 50.0);
    final keypadButtonSize = isVerySmallScreen ? 45.0 : (isSmallScreen ? 50.0 : 55.0);
    final actionButtonHeight = isVerySmallScreen ? 40.0 : (isSmallScreen ? 45.0 : 50.0);
    final spacing = isVerySmallScreen ? 8.0 : (isSmallScreen ? 12.0 : 16.0);
    final padding = isVerySmallScreen ? 12.0 : (isSmallScreen ? 16.0 : 20.0);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: const Text('Reto del Día'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentWarm),
          ),
        ),
      );
    }

    if (_challenge == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: const Text('Reto del Día'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el reto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _loadDailyChallenge();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final currentPhase = _challenge!.phases[_challenge!.currentPhase];
    final wallet = StorageService.getWallet();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Reto del Día'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  // Header con información del reto
                  SizedBox(
                    height: headerHeight,
                    child: _buildChallengeHeader(isSmallScreen, isVerySmallScreen),
                  ),
                  SizedBox(height: spacing),
                  
                  // Progreso de fases
                  SizedBox(
                    height: progressHeight,
                    child: _buildPhaseProgress(),
                  ),
                  SizedBox(height: spacing),
                  
                  // Ecuación actual
                  _buildCurrentPhase(currentPhase, phaseTitleSize, equationSize, spacing),
                  SizedBox(height: spacing),
                  
                  // Input del usuario
                  _buildInputDisplay(currentPhase, inputBoxSize, isSmallScreen, isVerySmallScreen),
                  SizedBox(height: spacing),
                  
                  // Keypad
                  _buildKeypad(keypadButtonSize, isSmallScreen, isVerySmallScreen),
                  SizedBox(height: spacing),
                  
                  // Botones de acción
                  _buildActionButtons(currentPhase, wallet, actionButtonHeight, isSmallScreen, isVerySmallScreen),
                  
                  // Espacio adicional al final para evitar overflow
                  SizedBox(height: padding),
                ],
              ),
            ),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeHeader(bool isSmallScreen, bool isVerySmallScreen) {
    final headerPadding = isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0);
    final titleSize = isVerySmallScreen ? 10.0 : (isSmallScreen ? 11.0 : 12.0);
    final streakSize = isVerySmallScreen ? 18.0 : (isSmallScreen ? 20.0 : 22.0);
    final iconSize = isVerySmallScreen ? 20.0 : (isSmallScreen ? 22.0 : 24.0);
    final borderRadius = isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0);
    
    return FutureBuilder<DailyChallengeStats>(
      future: StorageService.getDailyChallengeStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(headerPadding),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.accentWarm.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentWarm),
              ),
            ),
          );
        }

        final stats = snapshot.data ?? DailyChallengeStats(
          currentStreak: 0,
          bestStreak: 0,
          totalCompleted: 0,
          totalCoinsEarned: 0,
          lastCompletedDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        
        return Container(
          padding: EdgeInsets.all(headerPadding),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.accentWarm.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Racha Actual',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                        fontSize: titleSize,
                      ),
                    ),
                    Text(
                      '${stats.currentStreak} días',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.accentWarm,
                        fontWeight: FontWeight.bold,
                        fontSize: streakSize,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(headerPadding * 0.5),
                decoration: BoxDecoration(
                  color: AppColors.accentWarm.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(borderRadius * 0.75),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: AppColors.accentWarm,
                  size: iconSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhaseProgress() {
    return Row(
      children: _challenge!.phases.map((phase) {
        final isCompleted = phase.isCompleted;
        final isCurrent = phase.phaseNumber == _challenge!.currentPhase + 1;
        
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            decoration: BoxDecoration(
              color: isCompleted 
                ? AppColors.success 
                : isCurrent 
                  ? AppColors.accentWarm 
                  : AppColors.textSecondaryDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentPhase(ChallengePhase phase, double phaseTitleSize, double equationSize, double spacing) {
    final hintPadding = spacing * 0.75;
    final hintIconSize = spacing * 1.5;
    final hintBorderRadius = spacing * 0.75;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'FASE ${phase.phaseNumber}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.accentWarm,
              fontWeight: FontWeight.bold,
              fontSize: phaseTitleSize,
            ),
          ),
          SizedBox(height: spacing),
          Text(
            phase.equation,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
              fontSize: equationSize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing),
          if (_showHint) ...[
            Container(
              padding: EdgeInsets.all(hintPadding),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(hintBorderRadius),
                border: Border.all(
                  color: AppColors.accentWarm.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: AppColors.accentWarm,
                    size: hintIconSize,
                  ),
                  SizedBox(width: hintPadding * 0.5),
                  Flexible(
                    child: Text(
                      _currentHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontSize: phaseTitleSize * 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputDisplay(ChallengePhase phase, double inputBoxSize, bool isSmallScreen, bool isVerySmallScreen) {
    final containerPadding = isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0);
    final titleSize = isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0);
    final inputMargin = isVerySmallScreen ? 3.0 : (isSmallScreen ? 4.0 : 4.0);
    final inputBorderRadius = isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 12.0);
    final inputTextSize = isVerySmallScreen ? 16.0 : (isSmallScreen ? 18.0 : 20.0);
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(containerPadding),
        border: Border.all(
          color: AppColors.textSecondaryDark.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Tus respuestas:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: titleSize,
            ),
          ),
          SizedBox(height: containerPadding * 0.75),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(phase.placeholders.length, (index) {
              final isCurrent = index == _currentAnswerIndex;
              final hasValue = _currentAnswers[index] > 0;
              
              return Container(
                margin: EdgeInsets.symmetric(horizontal: inputMargin),
                width: inputBoxSize,
                height: inputBoxSize,
                decoration: BoxDecoration(
                  color: isCurrent 
                    ? AppColors.accentWarm.withOpacity(0.2)
                    : hasValue 
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.cardDark,
                  borderRadius: BorderRadius.circular(inputBorderRadius),
                  border: Border.all(
                    color: isCurrent 
                      ? AppColors.accentWarm 
                      : hasValue 
                        ? AppColors.success 
                        : AppColors.textSecondaryDark.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    hasValue ? _currentAnswers[index].toString() : '?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isCurrent 
                        ? AppColors.accentWarm 
                        : hasValue 
                          ? AppColors.success 
                          : AppColors.textSecondaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: inputTextSize,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(double keypadButtonSize, bool isSmallScreen, bool isVerySmallScreen) {
    return NumberKeypad(
      onNumberPressed: _onNumberPressed,
      onBackspace: _onBackspace,
      onConfirm: _onConfirm,
      isConfirmEnabled: _currentAnswerIndex == _challenge!.phases[_challenge!.currentPhase].placeholders.length,
      allowDecimals: false,
      isSmallScreen: isSmallScreen,
      isVerySmallScreen: isVerySmallScreen,
    );
  }

  Widget _buildActionButtons(ChallengePhase phase, Wallet wallet, double actionButtonHeight, bool isSmallScreen, bool isVerySmallScreen) {
    final buttonSpacing = isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 12.0);
    final buttonPadding = isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 12.0);
    final buttonFontSize = isVerySmallScreen ? 11.0 : (isSmallScreen ? 12.0 : 14.0);
    final iconSize = isVerySmallScreen ? 16.0 : (isSmallScreen ? 18.0 : 20.0);
    
    return Row(
      children: [
        // Botón de pista
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showHint ? null : _buyHint,
            icon: Icon(Icons.lightbulb, size: iconSize),
            label: Text(
              'Pista (${wallet.coins >= 5 ? '5' : '❌'})',
              style: TextStyle(fontSize: buttonFontSize),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentWarm,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: buttonPadding),
            ),
          ),
        ),
        SizedBox(width: buttonSpacing),
        
        // Botón de reintentar
        Expanded(
          child: ElevatedButton.icon(
            onPressed: phase.attempts > 0 ? _retryPhase : null,
            icon: Icon(Icons.replay, size: iconSize),
            label: Text(
              'Reintentar (${wallet.coins >= 5 ? '5' : '❌'})',
              style: TextStyle(fontSize: buttonFontSize),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.hardPrimary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: buttonPadding),
            ),
          ),
        ),
      ],
    );
  }
}
