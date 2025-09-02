import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reto_matematico/theme/app_theme.dart';
import 'package:reto_matematico/features/game/domain/models.dart';
import 'dart:ui';

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final bool isHighlighted;
  final bool isSmallScreen; // Nuevo parámetro para pantallas pequeñas

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.isHighlighted = false,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? AppTheme.easyModeColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16, 
        vertical: isSmallScreen ? 12 : 16
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.cardDark,
        border: Border.all(
          color: chipColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryDark,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 10 : 11,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 3 : 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: isSmallScreen ? 16 : 18,
                      color: chipColor,
                    ),
                    SizedBox(width: isSmallScreen ? 3 : 4),
                  ],
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen 
                        ? (isHighlighted ? 16 : 14) 
                        : (isHighlighted ? 18 : 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: 0.2,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class StreakChip extends StatelessWidget {
  final int streak;
  final int bestStreak;
  final GameMode mode;
  final bool isSmallScreen; // Nuevo parámetro para pantallas pequeñas

  const StreakChip({
    super.key,
    required this.streak,
    required this.bestStreak,
    required this.mode,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNewRecord = streak > bestStreak;
    final color = mode == GameMode.easy ? AppTheme.easyModeColor : AppTheme.hardModeColor;

    return StatChip(
      label: 'Racha',
      value: streak.toString(),
      icon: Icons.local_fire_department,
      color: color,
      isHighlighted: isNewRecord,
      isSmallScreen: isSmallScreen,
    );
  }
}

class RecordChip extends StatelessWidget {
  final int bestStreak;
  final GameMode mode;
  final bool isSmallScreen; // Nuevo parámetro para pantallas pequeñas

  const RecordChip({
    super.key,
    required this.bestStreak,
    required this.mode,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = mode == GameMode.easy ? AppTheme.easyModeColor : AppTheme.hardModeColor;

    return StatChip(
      label: 'Récord',
      value: bestStreak.toString(),
      icon: Icons.emoji_events,
      color: color,
      isSmallScreen: isSmallScreen,
    );
  }
}

class CoinChip extends StatelessWidget {
  final int coins;
  final bool isSmallScreen; // Nuevo parámetro para pantallas pequeñas

  const CoinChip({
    super.key,
    required this.coins,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return StatChip(
      label: 'Monedas',
      value: coins.toString(),
      icon: Icons.monetization_on,
      color: AppTheme.coinColor,
      isSmallScreen: isSmallScreen,
    );
  }
}
