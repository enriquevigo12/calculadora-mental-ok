import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reto_matematico/theme/app_theme.dart';

class NumberKeypad extends StatefulWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback onConfirm;
  final bool isConfirmEnabled;
  final bool allowDecimals; // Nuevo parámetro para permitir decimales
  final bool isSmallScreen; // Nuevo parámetro para pantallas pequeñas
  final bool isVerySmallScreen; // Nuevo parámetro para pantallas muy pequeñas

  const NumberKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspace,
    required this.onConfirm,
    this.isConfirmEnabled = false,
    this.allowDecimals = false, // Por defecto no permitir decimales
    this.isSmallScreen = false,
    this.isVerySmallScreen = false,
  });

  @override
  State<NumberKeypad> createState() => _NumberKeypadState();
}

class _NumberKeypadState extends State<NumberKeypad> {
  static const List<String> _numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

  @override
  Widget build(BuildContext context) {
    final buttonSpacing = widget.isVerySmallScreen ? 1.0 : (widget.isSmallScreen ? 1.5 : 2.0);
    final rowSpacing = widget.isVerySmallScreen ? 1.0 : (widget.isSmallScreen ? 1.5 : 2.0);
    
    return Container(
      padding: EdgeInsets.all(buttonSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila de números 1-3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _numbers.take(3).map((number) => _buildKey(number)).toList(),
          ),
          SizedBox(height: rowSpacing),
          
          // Fila de números 4-6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _numbers.skip(3).take(3).map((number) => _buildKey(number)).toList(),
          ),
          SizedBox(height: rowSpacing),
          
          // Fila de números 7-9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _numbers.skip(6).take(3).map((number) => _buildKey(number)).toList(),
          ),
          SizedBox(height: rowSpacing),
          
          // Fila final: backspace, 0 y decimal (centrados), confirmar
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centrar toda la fila
            children: [
              // Botón backspace a la izquierda
              _buildActionKey(
                icon: Icons.backspace_outlined,
                onPressed: widget.onBackspace,
                color: AppTheme.errorColor,
              ),
              
              SizedBox(width: widget.isSmallScreen ? 8 : 12), // Espacio reducido
              
              // 0 y decimal centrados
              if (widget.allowDecimals) ...[
                _buildKey('0'),
                SizedBox(width: widget.isSmallScreen ? 6 : 8),
                _buildKey('.'),
              ] else ...[
                _buildKey('0'),
              ],
              
              SizedBox(width: widget.isSmallScreen ? 8 : 12), // Espacio reducido
              
              // Botón confirmar a la derecha
              _buildActionKey(
                icon: Icons.check,
                onPressed: widget.isConfirmEnabled ? widget.onConfirm : null,
                color: widget.isConfirmEnabled ? AppTheme.successColor : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String number) {
    return _KeypadButton(
      child: Text(
        number,
        style: TextStyle(
          fontSize: widget.isVerySmallScreen ? 22 : (widget.isSmallScreen ? 24 : 28),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
      onPressed: () => widget.onNumberPressed(number),
      isSmallScreen: widget.isSmallScreen,
      isVerySmallScreen: widget.isVerySmallScreen,
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return _KeypadButton(
      child: Icon(
        icon,
        size: widget.isVerySmallScreen ? 22 : (widget.isSmallScreen ? 24 : 28),
        color: Colors.white,
      ),
      onPressed: onPressed,
      backgroundColor: color,
      isSmallScreen: widget.isSmallScreen,
      isVerySmallScreen: widget.isVerySmallScreen,
    );
  }
}

class _KeypadButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final bool isSmallScreen;
  final bool isVerySmallScreen;

  const _KeypadButton({
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.isSmallScreen = false,
    this.isVerySmallScreen = false,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final backgroundColor = widget.backgroundColor ?? AppColors.easyPrimary;
    
    // Calcular tamaño del botón según la pantalla
    final buttonSize = widget.isVerySmallScreen ? 44.0 : (widget.isSmallScreen ? 48.0 : 52.0);
    final borderRadius = widget.isVerySmallScreen ? 16.0 : (widget.isSmallScreen ? 18.0 : 20.0);

    return GestureDetector(
      onTapDown: isEnabled ? _onTapDown : null,
      onTapUp: isEnabled ? _onTapUp : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor,
                    backgroundColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Center(child: widget.child),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 200.ms).scale(
          begin: const Offset(0.8, 0.8),
          duration: 200.ms,
          curve: Curves.elasticOut,
        );
  }
}
