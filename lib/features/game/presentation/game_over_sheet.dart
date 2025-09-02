import 'package:flutter/material.dart';
import 'package:reto_matematico/features/game/data/session_repo.dart';
import 'package:reto_matematico/features/game/domain/models.dart';
import 'package:reto_matematico/shared/widgets/primary_button.dart';
import 'package:reto_matematico/theme/app_theme.dart';
import 'package:reto_matematico/services/storage_service.dart';
import 'package:reto_matematico/services/ads_service.dart';
import 'package:reto_matematico/shared/utils/haptics.dart';

class GameOverSheet extends StatefulWidget {
  final SessionRepository sessionRepo;
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameOverSheet({
    super.key,
    required this.sessionRepo,
    required this.onContinue,
    required this.onRestart,
    required this.onExit,
  });

  @override
  State<GameOverSheet> createState() => _GameOverSheetState();
}

class _GameOverSheetState extends State<GameOverSheet> {
  bool _isLoadingAd = false;
  bool _isLoadingContinue = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.sessionRepo.currentSession;
    if (session == null) return const SizedBox.shrink();
    
    final stats = StorageService.getStats();
    final wallet = StorageService.getWallet();
    final bestStreak = session.mode == GameMode.easy 
        ? stats.bestStreakEasy 
        : stats.bestStreakHard;
    final isNewRecord = session.streak > bestStreak;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                isNewRecord ? '¡Enhorabuena! 🎉' : '¡Juego Terminado!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isNewRecord ? AppColors.success : AppColors.textPrimaryDark,
                ),
              ),
              if (isNewRecord) ...[
                const SizedBox(height: 8),
                Text(
                  '¡Has conseguido un nuevo récord!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              
              // Stats
              _buildStats(session, bestStreak, isNewRecord),
              const SizedBox(height: 24),
              
              // Continue options
              if (widget.sessionRepo.canContinue()) ...[
                _buildContinueOptions(wallet),
                const SizedBox(height: 16),
              ],
              
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(GameSession session, int bestStreak, bool isNewRecord) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNewRecord ? AppColors.success : AppColors.textSecondaryDark.withOpacity(0.3),
          width: isNewRecord ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Racha final:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Text(
                '${session.streak}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isNewRecord ? AppColors.success : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Récord anterior:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Text(
                '$bestStreak',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monedas ganadas:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Text(
                '${session.coinsEarned}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.coinColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isNewRecord) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '¡NUEVO RÉCORD!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildContinueOptions(Wallet wallet) {
    final continueCost = widget.sessionRepo.getContinueCost();
    final canAfford = wallet.coins >= continueCost;
    final canWatchAd = wallet.canWatchAd();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Continuar racha:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 12),
        
        // Continuar con monedas
        PrimaryButton(
          text: 'Continuar por $continueCost monedas',
          icon: Icons.replay,
          onPressed: canAfford ? _continueWithCoins : null,
          isLoading: _isLoadingContinue,
          backgroundColor: canAfford ? AppTheme.warningColor : Colors.grey,
        ),
        const SizedBox(height: 8),
        
        // Ver anuncio
        PrimaryButton(
          text: canWatchAd ? 'Ver anuncio (+1 moneda)' : 'Anuncio no disponible',
          icon: Icons.play_circle_outline,
          onPressed: canWatchAd ? _watchAd : null,
          isLoading: _isLoadingAd,
          backgroundColor: canWatchAd ? Colors.blue : Colors.grey,
        ),
        
        if (!canWatchAd) ...[
          const SizedBox(height: 8),
          Text(
            'Disponible en ${_formatCooldown(wallet.adCooldownUntil)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: 'Reintentar',
            icon: Icons.refresh,
            onPressed: widget.onRestart,
            backgroundColor: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            text: 'Salir',
            icon: Icons.exit_to_app,
            onPressed: widget.onExit,
            backgroundColor: AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Future<void> _continueWithCoins() async {
    setState(() {
      _isLoadingContinue = true;
    });
    
    try {
      final success = await widget.sessionRepo.continueSession();
      if (success) {
        Haptics.success();
        widget.onContinue();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes suficientes monedas')),
        );
      }
    } finally {
      setState(() {
        _isLoadingContinue = false;
      });
    }
  }

  Future<void> _watchAd() async {
    setState(() {
      _isLoadingAd = true;
    });
    
    try {
      final success = await AdsService.showRewardedAd();
      if (success) {
        Haptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡+1 moneda ganada!')),
        );
        // Forzar actualización de la UI para mostrar las nuevas monedas
        setState(() {});
        // Pequeño delay para asegurar que se guarde el wallet
        await Future.delayed(const Duration(milliseconds: 100));
        widget.onContinue();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo mostrar el anuncio')),
        );
      }
    } finally {
      setState(() {
        _isLoadingAd = false;
      });
    }
  }

  String _formatCooldown(DateTime? cooldownUntil) {
    if (cooldownUntil == null) return '';
    
    final remaining = cooldownUntil.difference(DateTime.now());
    if (remaining.isNegative) return '';
    
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

