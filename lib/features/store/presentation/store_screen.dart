import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reto_matematico/features/store/data/wallet_repo.dart';
import 'package:reto_matematico/shared/widgets/primary_button.dart';
import 'package:reto_matematico/theme/app_theme.dart';
import 'package:reto_matematico/shared/utils/haptics.dart';
import 'package:reto_matematico/services/storage_service.dart';
import 'package:reto_matematico/services/ads_service.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  final StoreRepository _storeRepo = StoreRepository();
  bool _isLoadingAd = false;
  bool _isLoadingBonus = false;
  
  // Para forzar actualización del wallet
  int _walletUpdateCounter = 0;

  @override
  Widget build(BuildContext context) {
    // Recargar el wallet para obtener los datos más recientes
    final wallet = StorageService.getWallet();
    
    // Usar _walletUpdateCounter para forzar rebuild cuando cambie
    final updateCounter = _walletUpdateCounter;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Tienda'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bono diario
              _buildDailyBonusCard(wallet),
              const SizedBox(height: 24),
              
              // Anuncio recompensado
              _buildRewardedAdCard(wallet),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildDailyBonusCard(Wallet wallet) {
    final canClaim = _storeRepo.canClaimDailyBonus();
    final bonusAmount = _storeRepo.getDailyBonusAmount();
    final streak = _storeRepo.getDailyBonusStreak();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: canClaim ? AppTheme.successColor : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bono Diario',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    Text(
                      'Racha: $streak días',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (canClaim)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '¡Disponible!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '+$bonusAmount monedas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.coinColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PrimaryButton(
                text: canClaim ? 'Reclamar' : 'Mañana',
                onPressed: canClaim ? _claimDailyBonus : null,
                isLoading: _isLoadingBonus,
                backgroundColor: canClaim ? AppTheme.successColor : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardedAdCard(Wallet wallet) {
    // Recargar el estado del anuncio para obtener datos actualizados
    final currentWallet = StorageService.getWallet();
    final canWatch = currentWallet.canWatchAd();
    final cooldown = _storeRepo.getAdCooldownRemaining();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: canWatch ? Colors.blue : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anuncio Recompensado',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    Text(
                      '+1 moneda por ver anuncio',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '+1 moneda',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.coinColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!canWatch && cooldown != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Disponible en ${_formatCooldown(cooldown)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PrimaryButton(
                text: canWatch ? 'Ver Anuncio' : 'No disponible',
                onPressed: canWatch ? _watchRewardedAd : null,
                isLoading: _isLoadingAd,
                backgroundColor: canWatch ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }



  Future<void> _claimDailyBonus() async {
    setState(() {
      _isLoadingBonus = true;
    });
    
    try {
      final success = await _storeRepo.claimDailyBonus();
      if (success) {
        Haptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bono diario reclamado! +${_storeRepo.getDailyBonusAmount()} monedas'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() {});
      }
    } finally {
      setState(() {
        _isLoadingBonus = false;
      });
    }
  }

  Future<void> _watchRewardedAd() async {
    setState(() {
      _isLoadingAd = true;
    });
    
    try {
      // Usar AdsService directamente para actualización inmediata
      final success = await AdsService.showRewardedAd();
      if (success) {
        Haptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡+1 moneda ganada!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Forzar actualización inmediata del wallet
        setState(() {
          _walletUpdateCounter++;
        });
        
        // Pequeño delay adicional para asegurar que se guarde
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Segunda actualización para asegurar que se muestre
        setState(() {
          _walletUpdateCounter++;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo mostrar el anuncio'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingAd = false;
      });
    }
  }



  String _formatCooldown(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
