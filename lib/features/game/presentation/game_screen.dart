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
import 'package:calculadora_mental/services/ads_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

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
  BannerAd? _bannerAd;
  
  // Para forzar actualización del wallet
  int _walletUpdateCounter = 0;
  
  // Timer
  Timer? _timer;
  int _timeRemaining = 12;

  @override
  void initState() {
    super.initState();
    _gameMode = widget.mode == 'easy' ? GameMode.easy : GameMode.hard;
    _sessionRepo = SessionRepository();
    _settings = GameSettings.fromStorage();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    _loadBannerAd();
    _startGame();
  }

  void _startGame() {
    _sessionRepo.startSession(_gameMode, _settings);
    _currentOperation = _sessionRepo.getNextOperation();
    _currentInput = '';
    _isCorrect = false;
    _showFeedback = false;
    _isGameOver = false;
    _startTimer();
  }

  void _loadBannerAd() {
    _bannerAd = AdsService.createBannerAd();
    _bannerAd!.load();
  }

  void _refreshWallet() {
    setState(() {
      _walletUpdateCounter++;
    });
  }

  void _startTimer() {
    _timeRemaining = _settings.timePerOperation;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer?.cancel();
          _handleTimeUp();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    _timeRemaining = _settings.timePerOperation;
  }

  void _handleTimeUp() {
    if (!_isGameOver) {
      setState(() {
        _isGameOver = true;
      });
      
      Haptics.error();
      _showGameOverSheet();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bannerAd?.dispose();
    _sessionRepo.dispose();
    _timer?.cancel();
    super.dispose();
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
    
    dynamic answer;
    
    // Intentar parsear como entero primero
    answer = int.tryParse(_currentInput);
    
    // Si no es entero y se permiten decimales, intentar como double
    if (answer == null && _gameMode == GameMode.easy && _settings.allowDecimals) {
      answer = double.tryParse(_currentInput);
    }
    
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
    
    // Resetear timer para la nueva operación
    _resetTimer();
    _startTimer();
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
      _walletUpdateCounter++; // Forzar actualización del wallet
    });
    
    // Resetear timer y continuar
    _resetTimer();
    _startTimer();
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
    
    // Resetear timer
    _resetTimer();
    _startTimer();
  }

  void _exitGame() async {
    await _sessionRepo.endSession();
    if (mounted) {
      context.go('/');
    }
  }



  @override
  Widget build(BuildContext context) {
    final session = _sessionRepo.currentSession;
    if (session == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final stats = StorageService.getStats();
    final wallet = StorageService.getWallet();
    
    // Detectar tamaño de pantalla usando MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;
    final isNarrowScreen = screenWidth < 400;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Modo ${_gameMode == GameMode.easy ? 'Fácil' : 'Difícil'}',
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: _showPauseMenu,
        ),
        actions: [],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32, // 32 para el padding
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Header con stats
                          _buildHeader(session, stats, wallet, isSmallScreen, isVerySmallScreen),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          
                          // Operación actual
                          Expanded(
                            child: _buildOperationDisplay(isSmallScreen, isVerySmallScreen),
                          ),
                          
                          // Input del usuario
                          _buildInputDisplay(isSmallScreen),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          
                          // Keypad
                          _buildKeypad(isSmallScreen, isVerySmallScreen),
                          
                          // Banner ad
                          if (_bannerAd != null) ...[
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Container(
                              width: _bannerAd!.size.width.toDouble(),
                              height: _bannerAd!.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
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

  Widget _buildHeader(GameSession session, Stats stats, Wallet wallet, bool isSmallScreen, bool isVerySmallScreen) {
    // Recargar el wallet para obtener los datos más recientes
    final currentWallet = StorageService.getWallet();
    
    return Column(
      children: [
        // Timer
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 10 : 12, 
            vertical: isSmallScreen ? 4 : 6
          ),
          decoration: BoxDecoration(
            color: _timeRemaining <= 3 ? AppTheme.errorColor : AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _timeRemaining <= 3 ? AppTheme.errorColor : AppColors.textSecondaryDark.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: _timeRemaining <= 3 ? Colors.white : AppColors.textPrimaryDark,
                size: isSmallScreen ? 14 : 16,
              ),
              SizedBox(width: isSmallScreen ? 4 : 6),
              Text(
                '$_timeRemaining',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _timeRemaining <= 3 ? Colors.white : AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : null,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Stats chips
        Row(
          children: [
            Expanded(
              child: StreakChip(
                streak: session.streak,
                bestStreak: _gameMode == GameMode.easy ? stats.bestStreakEasy : stats.bestStreakHard,
                mode: _gameMode,
                isSmallScreen: isSmallScreen,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: CoinChip(
                coins: currentWallet.coins,
                isSmallScreen: isSmallScreen,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: StatChip(
                label: 'Intentos',
                value: '${session.continuesUsed}/3',
                icon: Icons.replay,
                color: AppColors.accentWarm,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationDisplay(bool isSmallScreen, bool isVerySmallScreen) {
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
                fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : null),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              _sessionRepo.engine?.current.toString() ?? '0',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isVerySmallScreen ? 36 : (isSmallScreen ? 42 : 48),
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
            SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
            Text(
              'Aplicar operación:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w600,
                fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : null),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _sessionRepo.engine?.current.toString() ?? '0',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isVerySmallScreen ? 24 : (isSmallScreen ? 28 : 32),
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  _currentOperation!.displayText,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isVerySmallScreen ? 28 : (isSmallScreen ? 32 : 36),
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
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  '= ?',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isVerySmallScreen ? 24 : (isSmallScreen ? 28 : 32),
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

  Widget _buildInputDisplay(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _showFeedback 
            ? (_isCorrect ? AppColors.success : AppTheme.errorColor)
            : AppColors.textSecondaryDark.withOpacity(0.3),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: isSmallScreen ? 16 : null,
            ),
          ),
          Expanded(
            child: Text(
              _currentInput.isEmpty ? '0' : _currentInput,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _showFeedback 
                    ? (_isCorrect ? AppColors.success : AppColors.error)
                    : AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 18 : null,
              ),
            ),
          ),
          if (_showFeedback) ...[
            Icon(
              _isCorrect ? Icons.check_circle : Icons.cancel,
              color: _isCorrect ? AppColors.success : AppTheme.errorColor,
              size: isSmallScreen ? 20 : 24,
            ),
          ],
        ],
      ),
    ).animate().scale(
          begin: _showFeedback ? const Offset(1.05, 1.05) : const Offset(1.0, 1.0),
          duration: 200.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildKeypad(bool isSmallScreen, bool isVerySmallScreen) {
    return NumberKeypad(
      onNumberPressed: _onNumberPressed,
      onBackspace: _onBackspace,
      onConfirm: _onConfirm,
      isConfirmEnabled: _currentInput.isNotEmpty && !_isGameOver,
      allowDecimals: _gameMode == GameMode.easy && _settings.allowDecimals,
      isSmallScreen: isSmallScreen,
      isVerySmallScreen: isVerySmallScreen,
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
