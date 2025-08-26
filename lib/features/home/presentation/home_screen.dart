import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:calculadora_mental/theme/app_theme.dart';
import 'package:calculadora_mental/theme/animated_background.dart';
import 'package:calculadora_mental/shared/widgets/primary_button.dart';
import 'package:calculadora_mental/shared/widgets/stat_chip.dart';
import 'package:calculadora_mental/services/storage_service.dart';
import 'package:calculadora_mental/features/game/domain/models.dart';
import 'package:calculadora_mental/services/ads_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = AdsService.createBannerAd();
    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    final stats = StorageService.getStats();
    final wallet = StorageService.getWallet();
    
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),
                
                // Stats chips
                _buildStatsChips(stats, wallet),
                const SizedBox(height: 24),
                
                // Game mode cards
                Expanded(
                  child: _buildGameModes(),
                ),
                
                const SizedBox(height: 16),
                
                // Bottom buttons
                _buildBottomButtons(),
                
                // Banner ad
                if (_bannerAd != null)
                  Container(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Calculadora Mental',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entrena tu mente con cálculos rápidos',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsChips(Stats stats, Wallet wallet) {
    return Row(
      children: [
        Expanded(
          child: RecordChip(
            bestStreak: stats.bestStreakEasy,
            mode: GameMode.easy,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CoinChip(coins: wallet.coins),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RecordChip(
            bestStreak: stats.bestStreakHard,
            mode: GameMode.hard,
          ),
        ),
      ],
    );
  }

  Widget _buildGameModes() {
    return Column(
      children: [
        // Modos principales (uno al lado del otro)
        Expanded(
          child: Row(
            children: [
              // Modo Fácil
              Expanded(
                child: _buildModeCard(
                  title: 'Fácil',
                  subtitle: 'Suma y resta',
                  description: 'Operaciones simples',
                  gradient: AppGradients.easy,
                  icon: Icons.add_circle_outline,
                  onTap: () => context.go('/game/easy'),
                ),
              ),
              const SizedBox(width: 12),
              
              // Modo Difícil
              Expanded(
                child: _buildModeCard(
                  title: 'Difícil',
                  subtitle: 'Todas las operaciones',
                  description: 'Multiplicación y división',
                  gradient: AppGradients.hard,
                  icon: Icons.functions,
                  onTap: () => context.go('/game/hard'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Modos de práctica (más pequeños)
        Row(
          children: [
            // Práctica Fácil
            Expanded(
              child: _buildPracticeCard(
                title: 'Práctica',
                subtitle: 'Modo Fácil',
                gradient: AppGradients.easy.withOpacity(0.7),
                icon: Icons.school,
                onTap: () => context.go('/practice/easy'),
              ),
            ),
            const SizedBox(width: 12),
            
            // Práctica Difícil
            Expanded(
              child: _buildPracticeCard(
                title: 'Práctica',
                subtitle: 'Modo Difícil',
                gradient: AppGradients.hard.withOpacity(0.7),
                icon: Icons.school,
                onTap: () => context.go('/practice/hard'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPracticeCard({
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required String description,
    required LinearGradient gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
                      child: Container(
              padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(
          begin: 0.3,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'Tienda',
              icon: Icons.shopping_cart,
              onPressed: () => context.go('/store'),
              backgroundColor: AppColors.coinColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PrimaryButton(
              text: 'Stats',
              icon: Icons.bar_chart,
              onPressed: () => context.go('/stats'),
              backgroundColor: AppColors.hardPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PrimaryButton(
              text: 'Ajustes',
              icon: Icons.settings,
              onPressed: () => context.go('/settings'),
              backgroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
