import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:calculadora_mental/features/game/domain/models.dart';
import 'package:calculadora_mental/features/game/domain/game_settings.dart';
import 'package:calculadora_mental/features/game/domain/game_engine.dart';
import 'package:calculadora_mental/shared/widgets/number_keypad.dart';
import 'package:calculadora_mental/shared/utils/haptics.dart';
import 'package:calculadora_mental/theme/app_theme.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final String mode;

  const PracticeScreen({super.key, required this.mode});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  late GameMode _gameMode;
  late GameSettings _settings;
  late GameEngine _engine;
  
  StepOp? _currentOperation;
  String _currentInput = '';
  bool _isCorrect = false;
  bool _showFeedback = false;
  int _correctAnswers = 0;
  int _totalAnswers = 0;

  @override
  void initState() {
    super.initState();
    _gameMode = widget.mode == 'easy' ? GameMode.easy : GameMode.hard;
    _settings = GameSettings.fromStorage();
    _engine = GameEngine(mode: _gameMode, settings: _settings);
    
    _startPractice();
  }

  void _startPractice() {
    _engine.start();
    _currentOperation = _engine.nextOp();
    _currentInput = '';
    _isCorrect = false;
    _showFeedback = false;
  }

  void _onNumberPressed(String number) {
    setState(() {
      _currentInput += number;
    });
    
    Haptics.lightImpact();
  }

  void _onBackspace() {
    if (_currentInput.isEmpty) return;
    
    setState(() {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    });
    
    Haptics.lightImpact();
  }

  void _onConfirm() {
    if (_currentInput.isEmpty) return;
    
    dynamic answer;
    
    // Intentar parsear como entero primero
    answer = int.tryParse(_currentInput);
    
    // Si no es entero y se permiten decimales, intentar como double
    if (answer == null && _gameMode == GameMode.easy && _settings.allowDecimals) {
      answer = double.tryParse(_currentInput);
    }
    
    if (answer == null) return;
    
    final isCorrect = _engine.check(answer);
    _totalAnswers++;
    
    setState(() {
      _isCorrect = isCorrect;
      _showFeedback = true;
      if (isCorrect) _correctAnswers++;
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
    // Siguiente operación
    _currentOperation = _engine.nextOp();
    _currentInput = '';
  }

  void _handleIncorrectAnswer() {
    // Mostrar la respuesta correcta
    _currentInput = _engine.current.toString();
  }

  void _nextOperation() {
    _currentOperation = _engine.nextOp();
    _currentInput = '';
    _isCorrect = false;
    _showFeedback = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Práctica ${_gameMode == GameMode.easy ? 'Fácil' : 'Difícil'}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Stats de práctica
              _buildPracticeStats(),
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
    );
  }

  Widget _buildPracticeStats() {
    final accuracy = _totalAnswers > 0 ? (_correctAnswers / _totalAnswers * 100).round() : 0;
    
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Aciertos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                Text(
                  '$_correctAnswers',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Precisión',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                Text(
                  '$accuracy%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.accentWarm,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                Text(
                  '$_totalAnswers',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
              _engine.current.toString(),
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
            const SizedBox(height: 24),
            Text(
              'Aplicar operación:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _engine.current.toString(),
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
            ),
          ),
          Expanded(
            child: Text(
              _currentInput.isEmpty ? '0' : _currentInput,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_showFeedback) ...[
            Icon(
              _isCorrect ? Icons.check_circle : Icons.cancel,
              color: _isCorrect ? AppColors.success : AppTheme.errorColor,
              size: 24,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return NumberKeypad(
      onNumberPressed: _onNumberPressed,
      onBackspace: _onBackspace,
      onConfirm: _onConfirm,
      isConfirmEnabled: _currentInput.isNotEmpty,
      allowDecimals: _gameMode == GameMode.easy && _settings.allowDecimals,
    );
  }
}
