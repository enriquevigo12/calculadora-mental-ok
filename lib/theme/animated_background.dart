import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:reto_matematico/theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _particleAnimation;

  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));
    
    _initializeParticles();
  }

  void _initializeParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.5 + 0.1,
        opacity: _random.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_gradientController, _particleController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Fondo con gradiente animado
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.primaryColor ?? AppColors.easyPrimary.withOpacity(0.15),
                    widget.secondaryColor ?? AppColors.hardPrimary.withOpacity(0.15),
                    widget.primaryColor ?? AppColors.accentWarm.withOpacity(0.1),
                  ],
                  stops: [
                    0.0,
                    _gradientAnimation.value,
                    1.0,
                  ],
                ),
              ),
            ),
            
            // Partículas animadas
            CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                animationValue: _particleAnimation.value,
              ),
              size: Size.infinite,
            ),
            
            // Contenido
            widget.child,
          ],
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Mover partícula
      particle.y -= particle.speed * 0.01;
      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = math.Random().nextDouble();
      }

      // Dibujar partícula
      final x = particle.x * size.width;
      final y = particle.y * size.height;
      
      // Color de partícula adaptado al tema
      final particleColor = AppColors.easyPrimary.withOpacity(particle.opacity * 0.3);
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint..color = particleColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
