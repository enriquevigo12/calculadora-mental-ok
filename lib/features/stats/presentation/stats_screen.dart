import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reto_matematico/services/storage_service.dart';
import 'package:reto_matematico/theme/app_theme.dart';
import 'package:reto_matematico/shared/widgets/stat_chip.dart';
import 'package:reto_matematico/features/game/domain/models.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    final stats = StorageService.getStats();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen general
              _buildSummarySection(stats),
              const SizedBox(height: 32),
              
              // Récords por modo
              _buildRecordsSection(stats),
              const SizedBox(height: 32),
              
              // Distribución por operación
              _buildOperationDistribution(stats),
              const SizedBox(height: 32),
              
              // Tiempo promedio
              _buildTimeStats(stats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(Stats stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.easyModeColor,
            AppTheme.hardModeColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.easyModeColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen General',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total respuestas',
                  value: '${stats.totalAnswers}',
                  icon: Icons.question_answer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Aciertos',
                  value: '${stats.totalCorrect}',
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Precisión',
                  value: '${stats.accuracyPercentage.toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Tiempo promedio',
                  value: '${(stats.averageTimeMs / 1000).toStringAsFixed(1)}s',
                  icon: Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsSection(Stats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Récords',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRecordCard(
                title: 'Modo Fácil',
                record: stats.bestStreakEasy,
                color: AppTheme.easyModeColor,
                icon: Icons.add_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRecordCard(
                title: 'Modo Difícil',
                record: stats.bestStreakHard,
                color: AppTheme.hardModeColor,
                icon: Icons.functions,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordCard({
    required String title,
    required int record,
    required Color color,
    required IconData icon,
  }) {
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
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$record',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'mejor racha',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationDistribution(Stats stats) {
    final operations = [
      {'name': 'Suma', 'key': 'plus', 'icon': Icons.add, 'color': Colors.green},
      {'name': 'Resta', 'key': 'minus', 'icon': Icons.remove, 'color': Colors.red},
      {'name': 'Multiplicación', 'key': 'times', 'icon': Icons.close, 'color': Colors.blue},
      {'name': 'División', 'key': 'div', 'icon': Icons.functions, 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución por Operación',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: operations.map((op) {
              final count = stats.getOperationCount(op['key'] as String);
              final percentage = stats.totalAnswers > 0 
                  ? (count / stats.totalAnswers * 100).toStringAsFixed(1)
                  : '0.0';
              
              return Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        op['icon'] as IconData,
                        color: op['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              op['name'] as String,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                            Text(
                              '$count respuestas ($percentage%)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: stats.totalAnswers > 0 ? count / stats.totalAnswers : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(op['color'] as Color),
                  ),
                  if (op != operations.last) const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStats(Stats stats) {
    final avgTimeSeconds = stats.averageTimeMs / 1000;
    String timeCategory;
    Color timeColor;
    
    if (avgTimeSeconds < 3) {
      timeCategory = 'Excelente';
      timeColor = AppTheme.successColor;
    } else if (avgTimeSeconds < 5) {
      timeCategory = 'Bueno';
      timeColor = AppTheme.warningColor;
    } else {
      timeCategory = 'Necesita práctica';
      timeColor = AppTheme.errorColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiempo de Respuesta',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: timeColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiempo promedio',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        Text(
                          '${avgTimeSeconds.toStringAsFixed(1)} segundos',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: timeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: timeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      timeCategory,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: timeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTimeBar(avgTimeSeconds),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBar(double avgTimeSeconds) {
    final normalizedTime = (avgTimeSeconds / 10).clamp(0.0, 1.0);
    Color barColor;
    
    if (avgTimeSeconds < 3) {
      barColor = AppTheme.successColor;
    } else if (avgTimeSeconds < 5) {
      barColor = AppTheme.warningColor;
    } else {
      barColor = AppTheme.errorColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rápido',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            Text(
              'Lento',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: normalizedTime,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
