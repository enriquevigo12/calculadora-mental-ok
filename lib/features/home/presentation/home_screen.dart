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
                _buildGameModes(),
                
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
    return Expanded(
      child: Column(
        children: [
          // Contador de días seguidos arriba
          _buildDailyChallengeStreak(),
          
          // Espaciado responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = MediaQuery.of(context).size.height;
              final isSmallScreen = screenHeight < 700;
              final isVerySmallScreen = screenHeight < 600;
              
              final spacing = isVerySmallScreen ? 18.0 : (isSmallScreen ? 22.0 : 26.0);
              
              return SizedBox(height: spacing);
            },
          ),
          
          // Área central con el botón del reto diario y botones orbitantes
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Detectar tamaño de pantalla
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                final isSmallScreen = screenHeight < 700;
                final isVerySmallScreen = screenHeight < 600;
                
                // Calcular tamaños responsivos más grandes
                final centerButtonSize = isVerySmallScreen ? 100.0 : (isSmallScreen ? 120.0 : 140.0);
                final orbitButtonSize = isVerySmallScreen ? 65.0 : (isSmallScreen ? 80.0 : 95.0);
                final practiceButtonSize = orbitButtonSize; // Mismo tamaño que los modos principales
                final orbitRadius = isVerySmallScreen ? 75.0 : (isSmallScreen ? 90.0 : 110.0);
                
                final centerX = constraints.maxWidth / 2;
                final centerY = constraints.maxHeight / 2;
                
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Botón de reto diario en el centro absoluto
                    Positioned(
                      left: centerX - (centerButtonSize / 2),
                      top: centerY - (centerButtonSize / 2),
                      child: _buildDailyChallengeButton(size: centerButtonSize),
                    ),
                    
                    // Botón Fácil - arriba-izquierda
                    Positioned(
                      left: centerX - orbitRadius - (orbitButtonSize / 2),
                      top: centerY - orbitRadius - (orbitButtonSize / 2),
                      child: _buildCircularModeCard(
                        title: 'Fácil',
                        gradient: AppGradients.easy,
                        icon: Icons.add_circle_outline,
                        onTap: () => context.go('/game/easy'),
                        size: orbitButtonSize,
                      ),
                    ),
                    
                    // Botón Difícil - arriba-derecha
                    Positioned(
                      left: centerX + orbitRadius - (orbitButtonSize / 2),
                      top: centerY - orbitRadius - (orbitButtonSize / 2),
                      child: _buildCircularModeCard(
                        title: 'Difícil',
                        gradient: AppGradients.hard,
                        icon: Icons.functions,
                        onTap: () => context.go('/game/hard'),
                        size: orbitButtonSize,
                      ),
                    ),
                    
                    // Botón Práctica Fácil - abajo-izquierda
                    Positioned(
                      left: centerX - orbitRadius - (practiceButtonSize / 2),
                      top: centerY + orbitRadius - (practiceButtonSize / 2),
                      child: _buildCircularPracticeCard(
                        title: 'Práctica',
                        subtitle: 'Fácil',
                        gradient: AppGradients.easy.withOpacity(0.7),
                        icon: Icons.school,
                        onTap: () => context.go('/practice/easy'),
                        size: practiceButtonSize,
                      ),
                    ),
                    
                    // Botón Práctica Difícil - abajo-derecha
                    Positioned(
                      left: centerX + orbitRadius - (practiceButtonSize / 2),
                      top: centerY + orbitRadius - (practiceButtonSize / 2),
                      child: _buildCircularPracticeCard(
                        title: 'Práctica',
                        subtitle: 'Difícil',
                        gradient: AppGradients.hard.withOpacity(0.7),
                        icon: Icons.school,
                        onTap: () => context.go('/practice/hard'),
                        size: practiceButtonSize,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeStreak() {
    // Por ahora usamos un valor falso, después se puede conectar con el sistema real
    final daysStreak = 7; // Días seguidos completando el reto
    
    // Detectar tamaño de pantalla para hacer el contador responsive
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;
    
    final padding = isVerySmallScreen ? 10.0 : (isSmallScreen ? 12.0 : 14.0);
    final iconSize = isVerySmallScreen ? 14.0 : (isSmallScreen ? 16.0 : 18.0);
    final fontSize = isVerySmallScreen ? 11.0 : (isSmallScreen ? 12.0 : 13.0);
    final borderRadius = isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.accentWarm.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppColors.accentWarm,
            size: iconSize,
          ),
          SizedBox(width: padding * 0.3),
          Text(
            '$daysStreak días',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(
          begin: 0.2,
          duration: 800.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildDailyChallengeButton({double size = 90}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentWarm,
            AppColors.accentWarm.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentWarm.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Por ahora no hace nada, solo visual
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Función de reto diario próximamente!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: size * 0.3, // Icono más grande
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  'Reto\nDiario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: size * 0.12, // Letra más grande
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 1000.ms).scale(
          begin: const Offset(0.8, 0.8),
          duration: 1000.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildCircularModeCard({
    required String title,
    required LinearGradient gradient,
    required IconData icon,
    required VoidCallback onTap,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono principal con efecto de brillo
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: size * 0.35, // Icono más grande
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: size * 0.18, // Letra más grande
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(
          begin: const Offset(0.8, 0.8),
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildCircularPracticeCard({
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required IconData icon,
    required VoidCallback onTap,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: size * 0.35, // Icono más grande
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: size * 0.16, // Letra más grande
                  ),
                  textAlign: TextAlign.center,
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
