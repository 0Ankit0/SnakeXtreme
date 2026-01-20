import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_colors.dart';

/// Animated background widget with gradient and floating particles
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showParticles = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particles = List.generate(15, (index) => Particle.random());
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated gradient background
        AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDark, // Ensure base opacity
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.backgroundDark,
                    Color.lerp(
                      AppColors.backgroundMid,
                      AppColors.primary.withValues(alpha: 0.3),
                      _gradientController.value * 0.3,
                    )!,
                    AppColors.backgroundLight,
                  ],
                  stops: [
                    0.0,
                    0.3 + (_gradientController.value * 0.2),
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),
        
        // Floating particles
        if (widget.showParticles)
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                ),
              );
            },
          ),
        
        // Gradient overlay for depth
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                AppColors.backgroundDark.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
        
        // Child content
        widget.child,
      ],
    );
  }
}

/// Particle data class
class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.opacity,
  });

  factory Particle.random() {
    final random = math.Random();
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
    ];
    return Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: random.nextDouble() * 4 + 2,
      speed: random.nextDouble() * 0.5 + 0.2,
      color: colors[random.nextInt(colors.length)],
      opacity: random.nextDouble() * 0.4 + 0.1,
    );
  }
}

/// Custom painter for particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final yOffset = ((particle.y + progress * particle.speed) % 1.2) - 0.1;
      
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(
        Offset(particle.x * size.width, yOffset * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
