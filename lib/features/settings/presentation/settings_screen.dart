import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reto_matematico/features/game/domain/game_settings.dart';
import 'package:reto_matematico/shared/widgets/primary_button.dart';
import 'package:reto_matematico/theme/app_theme.dart';
import 'package:reto_matematico/theme/theme_provider.dart';
import 'package:reto_matematico/services/storage_service.dart';
import 'package:reto_matematico/services/consent_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late GameSettings _settings;
  String _deviceId = '';
  String _appVersion = '';
  String _consentStatus = '';

  @override
  void initState() {
    super.initState();
    _settings = GameSettings.fromStorage();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final deviceId = await StorageService.getDeviceId();
    final packageInfo = await PackageInfo.fromPlatform();
    
    setState(() {
      _deviceId = deviceId;
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      _consentStatus = ConsentService.getConsentStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Ajustes'),
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
              // Configuración del juego
              _buildSection(
                title: 'Configuración del Juego',
                children: [
                  _buildRangeSlider(),
                  const SizedBox(height: 16),
                  _buildSwitches(),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Accesibilidad
              _buildSection(
                title: 'Accesibilidad',
                children: [
                  _buildAccessibilitySettings(),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Información
              _buildSection(
                title: 'Información',
                children: [
                  _buildInfoCards(),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Botones de acción
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildRangeSlider() {
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
          Text(
            'Rango de resultados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mínimo: ${_settings.minResult}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Slider(
                      value: _settings.minResult.toDouble(),
                      min: -100,
                      max: _settings.maxResult.toDouble(),
                      divisions: 50,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(minResult: value.toInt());
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Máximo: ${_settings.maxResult}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Slider(
                      value: _settings.maxResult.toDouble(),
                      min: _settings.minResult.toDouble(),
                      max: 500,
                      divisions: 50,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(maxResult: value.toInt());
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitches() {
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
          _buildSwitchTile(
            title: 'Permitir números negativos',
            subtitle: 'Incluir operaciones que resulten en números negativos',
            value: _settings.allowNegatives,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(allowNegatives: value);
              });
              _saveSettings();
            },
          ),
          const Divider(),
          _buildSwitchTile(
            title: 'Permitir decimales',
            subtitle: 'Incluir operaciones que resulten en números decimales',
            value: _settings.allowDecimals,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(allowDecimals: value);
              });
              _saveSettings();
            },
          ),
          const Divider(),
          _buildSwitchTile(
            title: 'Temporizador',
            subtitle: 'Mostrar tiempo transcurrido durante el juego',
            value: _settings.timer,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(timer: value);
              });
              _saveSettings();
            },
          ),
          const Divider(),
          _buildSwitchTile(
            title: 'Dificultad dinámica',
            subtitle: 'Ajustar automáticamente la dificultad según el rendimiento',
            value: _settings.difficultyAuto,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(difficultyAuto: value);
              });
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.easyModeColor,
    );
  }



  Widget _buildAccessibilitySettings() {
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
          _buildSwitchTile(
            title: 'Sonido',
            subtitle: 'Reproducir efectos de sonido',
            value: _settings.sound,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(sound: value);
              });
              _saveSettings();
            },
          ),
          const Divider(),
          _buildSwitchTile(
            title: 'Vibración',
            subtitle: 'Vibración háptica al tocar botones',
            value: _settings.haptics,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(haptics: value);
              });
              _saveSettings();
            },
          ),
          const Divider(),
          _buildSwitchTile(
            title: 'Alto contraste',
            subtitle: 'Mejorar el contraste visual',
            value: _settings.highContrast,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(highContrast: value);
              });
              _saveSettings();
            },
          ),
          const Divider(),
          _buildSwitchTile(
            title: 'Texto grande',
            subtitle: 'Aumentar el tamaño del texto',
            value: _settings.largeText,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(largeText: value);
              });
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoCard(
          title: 'ID del dispositivo',
          value: _deviceId,
          icon: Icons.phone_android,
          onTap: () => _copyToClipboard(_deviceId, 'ID del dispositivo'),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Versión de la app',
          value: _appVersion,
          icon: Icons.info,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Estado de consentimiento',
          value: _consentStatus,
          icon: Icons.privacy_tip,
          onTap: () => _requestConsent(),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.easyModeColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.copy,
                color: Colors.grey,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          text: 'Restaurar compras',
          icon: Icons.restore,
          onPressed: _restorePurchases,
          backgroundColor: Colors.blue,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          text: 'Restablecer datos',
          icon: Icons.refresh,
          onPressed: _resetData,
          backgroundColor: AppTheme.errorColor,
        ),
      ],
    );
  }

  Future<void> _saveSettings() async {
    await _settings.saveToStorage();
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copiado al portapapeles'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _requestConsent() async {
    await ConsentService.requestConsent();
    setState(() {
      _consentStatus = ConsentService.getConsentStatus();
    });
  }

  Future<void> _restorePurchases() async {
    // TODO: Implementar restauración de compras
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restauración de compras iniciada'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer datos'),
        content: const Text(
          '¿Estás seguro de que quieres restablecer todos los datos? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implementar restablecimiento de datos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos restablecidos'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}
