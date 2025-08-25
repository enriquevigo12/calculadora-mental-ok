import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:calculadora_mental/features/game/domain/models.dart';
import 'package:calculadora_mental/features/game/domain/game_settings.dart';
import 'package:calculadora_mental/features/game/data/session_repo.dart';
import 'package:calculadora_mental/shared/widgets/number_keypad.dart';
import 'package:calculadora_mental/shared/widgets/stat_chip.dart';
import 'package:calculadora_mental/shared/utils/haptics.dart';
import 'package:calculadora_mental/theme/app_theme.dart';
import 'package:calculadora_mental/services/storage_service.dart';
import 'package:calculadora_mental/services/analytics_service.dart';
import 'package:calculadora_mental/features/game/presentation/game_over_sheet.dart';
import 'package:confetti/confetti.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String mode;

  const GameScreen({super.key, required this.mode});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GameMode _gameMode;
  late SessionRepository _sessionRepo;
  late GameSettings _settings;
  
  StepOp? _currentOperation;
  String _currentInput = '';
  bool _isCorrect = false;
  bool _showFeedback = false;
  bool _isGameOver = false;
  
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _gameMode = widget.mode == 'easy' ? GameMode.easy : GameMode.hard;
    _sessionRepo = SessionRepository();
    _settings = GameSettings.fromStorage();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    _startGame();
  }

  void _startGame() {
    _sessionRepo.startSession(_gameMode, _settings);
    _currentOperation = _sessionRepo.getNextOperation();
    _currentInput = '';
    _isCorrect = false;
    _showFeedback = false;
    _isGameOver = false;
  }

  void _onNumberPressed(String number) {
    if (_isGameOver) return;
    
    setState(() {
      _currentInput += number;
    });
    
    Haptics.lightImpact();
  }

  void _onBackspace() {
    if (_isGameOver || _currentInput.isEmpty) return;
    
    setState(() {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    });
    
    Haptics.lightImpact();
  }

  void _onConfirm() {
    if (_isGameOver || _currentInput.isEmpty) return;
    
    final answer = int.tryParse(_currentInput);
    if (answer == null) return;
    
    final isCorrect = _sessionRepo.submitAnswer(answer);
    
    setState(() {
      _isCorrect = isCorrect;
      _showFeedback = true;
    });
    
    if (isCorrect) {
      Haptics.success();
      _handleCorrectAnswer();
    } else {
      Haptics.error();
      _handleIncorrectAnswer();
    }
    
    // Ocultar feedback después de un tiempo
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
        });
      }
    });
  }

  void _handleCorrectAnswer() {
    // Solo haptic feedback para aciertos, sin confetti
    Haptics.success();
    
    // Siguiente operación
    _currentOperation = _sessionRepo.getNextOperation();
    _currentInput = '';
  }

  void _handleIncorrectAnswer() {
    setState(() {
      _isGameOver = true;
    });
    
    // Mostrar confetti cuando se equivoca
    _confettiController.play();
    Haptics.error();
    
    // Mostrar GameOverSheet después de un breve delay para que se vea el confetti
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _showGameOverSheet();
      }
    });
  }

  void _showGameOverSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GameOverSheet(
        sessionRepo: _sessionRepo,
        onContinue: _continueGame,
        onRestart: _restartGame,
        onExit: _exitGame,
      ),
    );
  }

  void _continueGame() {
    Navigator.of(context).pop();
    setState(() {
      _isGameOver = false;
    });
  }

  void _restartGame() {
    // Solo cerrar el diálogo si está abierto
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    
    // Reiniciar completamente el estado
    setState(() {
      _currentInput = '';
      _isCorrect = false;
      _showFeedback = false;
      _isGameOver = false;
    });
    
    // Reiniciar la sesión y generar nueva operación
    _sessionRepo.startSession(_gameMode, _settings);
    _currentOperation = _sessionRepo.getNextOperation();
  }

  void _exitGame() async {
    await _sessionRepo.endSession();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _sessionRepo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _sessionRepo.currentSession;
    if (session == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final stats = StorageService.getStats();
    final wallet = StorageService.getWallet();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Modo ${_gameMode == GameMode.easy ? 'Fácil' : 'Difícil'}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _showPauseMenu,
        ),
        actions: [],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header con stats
                  _buildHeader(session, stats, wallet),
                  const SizedBox(height: 16),
                  
                  // Operación actual
                  Expanded(
                    child: _buildOperationDisplay(),
                  ),
                  
                  // Input del usuario
                  _buildInputDisplay(),
                  const SizedBox(height: 16),
                  
                  // Keypad
                  _buildKeypad(),
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

  Widget _buildHeader(GameSession session, Stats stats, Wallet wallet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StreakChip(
          streak: session.streak,
          bestStreak: _gameMode == GameMode.easy ? stats.bestStreakEasy : stats.bestStreakHard,
          mode: _gameMode,
        ),
        CoinChip(coins: wallet.coins),
        StatChip(
          label: 'Continuaciones',
          value: '${session.continuesUsed}/3',
          icon: Icons.replay,
          color: AppColors.accentWarm,
        ),
      ],
    );
  }

  Widget _buildOperationDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentOperation != null) ...[
            Text(
              'Valor actual:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _sessionRepo.engine?.current.toString() ?? '0',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 48,
                color: _gameMode == GameMode.easy ? AppColors.easyPrimary : AppColors.hardPrimary,
                shadows: [
                  Shadow(
                    color: (_gameMode == GameMode.easy ? AppColors.easyPrimary : AppColors.hardPrimary).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplicar operación:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _sessionRepo.engine?.current.toString() ?? '0',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _currentOperation!.displayText,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: AppColors.textPrimaryDark,
                    shadows: [
                      Shadow(
                        color: AppColors.textPrimaryDark.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '= ?',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.easyPrimary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Nuevo valor: ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryDark,
            ),
          ),
          Expanded(
                          child: Text(
                _currentInput.isEmpty ? '0' : _currentInput,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: _showFeedback 
                      ? (_isCorrect ? AppColors.success : AppColors.error)
                      : AppColors.textPrimaryDark,
                ),
              ),
          ),
        ],
      ),
    ).animate().scale(
          begin: _showFeedback ? const Offset(1.05, 1.05) : const Offset(1.0, 1.0),
          duration: 200.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildKeypad() {
    return NumberKeypad(
      onNumberPressed: _onNumberPressed,
      onBackspace: _onBackspace,
      onConfirm: _onConfirm,
      isConfirmEnabled: _currentInput.isNotEmpty && !_isGameOver,
    );
  }

  void _showPauseMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pausa'),
        content: const Text('¿Qué quieres hacer?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exitGame();
            },
            child: const Text('Salir'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
