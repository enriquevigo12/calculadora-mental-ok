import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:calculadora_mental/features/store/data/wallet_repo.dart';
import 'package:calculadora_mental/shared/widgets/primary_button.dart';
import 'package:calculadora_mental/theme/app_theme.dart';
import 'package:calculadora_mental/shared/utils/haptics.dart';
import 'package:calculadora_mental/services/storage_service.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  final StoreRepository _storeRepo = StoreRepository();
  bool _isLoadingAd = false;
  bool _isLoadingBonus = false;
  Map<String, bool> _loadingPurchases = {};

  @override
  Widget build(BuildContext context) {
    final wallet = _storeRepo.getWallet();
    final products = _storeRepo.getAvailableProducts();
    
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
              // Saldo
              _buildBalanceCard(wallet),
              const SizedBox(height: 24),
              
              // Bono diario
              _buildDailyBonusCard(wallet),
              const SizedBox(height: 24),
              
              // Anuncio recompensado
              _buildRewardedAdCard(wallet),
              const SizedBox(height: 24),
              
              // Productos IAP
              Expanded(
                child: _buildProductsList(products),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(Wallet wallet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.coinColor,
            AppTheme.coinColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.coinColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo actual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '${wallet.coins} monedas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final canWatch = _storeRepo.canWatchAd();
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

  Widget _buildProductsList(List<Map<String, dynamic>> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comprar Monedas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isLoading = _loadingPurchases[product['id']] ?? false;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.coinColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.monetization_on,
                        color: AppTheme.coinColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title'] ?? 'Monedas',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${product['coins']} monedas',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.coinColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product['price'] ?? '',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PrimaryButton(
                          text: isLoading ? '' : 'Comprar',
                          onPressed: isLoading ? null : () => _purchaseProduct(product['id']),
                          isLoading: isLoading,
                          backgroundColor: AppTheme.coinColor,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
      final success = await _storeRepo.watchRewardedAd();
      if (success) {
        Haptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡+10 monedas ganadas!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() {});
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

  Future<void> _purchaseProduct(String productId) async {
    setState(() {
      _loadingPurchases[productId] = true;
    });
    
    try {
      final success = await _storeRepo.purchaseCoins(productId);
      if (success) {
        Haptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Compra exitosa!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error en la compra'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _loadingPurchases[productId] = false;
      });
    }
  }

  String _formatCooldown(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
