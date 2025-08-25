import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:calculadora_mental/theme/app_theme.dart';

class NumberKeypad extends StatefulWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback onConfirm;
  final bool isConfirmEnabled;

  const NumberKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspace,
    required this.onConfirm,
    this.isConfirmEnabled = false,
  });

  @override
  State<NumberKeypad> createState() => _NumberKeypadState();
}

class _NumberKeypadState extends State<NumberKeypad> {
  static const List<String> _numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila de números 1-3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _numbers.take(3).map((number) => _buildKey(number)).toList(),
          ),
          const SizedBox(height: 8),
          
          // Fila de números 4-6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _numbers.skip(3).take(3).map((number) => _buildKey(number)).toList(),
          ),
          const SizedBox(height: 8),
          
          // Fila de números 7-9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _numbers.skip(6).take(3).map((number) => _buildKey(number)).toList(),
          ),
          const SizedBox(height: 8),
          
          // Fila final: 0, backspace, confirmar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('0'),
              _buildActionKey(
                icon: Icons.backspace_outlined,
                onPressed: widget.onBackspace,
                color: AppTheme.errorColor,
              ),
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
        style: const TextStyle(
          fontSize: 28,
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
        size: 28,
        color: Colors.white,
      ),
      onPressed: onPressed,
      backgroundColor: color,
    );
  }
}

class _KeypadButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const _KeypadButton({
    required this.child,
    this.onPressed,
    this.backgroundColor,
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor,
                    backgroundColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(20),
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
