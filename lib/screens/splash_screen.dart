import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../utils/app_colors.dart';
import 'menu_screen.dart';

/// Animated splash screen with logo and snake animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _snakeController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    
    _snakeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Navigate to menu after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                const MenuScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _snakeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background glow effect
            Center(
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 300 + (_glowController.value * 50),
                    height: 300 + (_glowController.value * 50),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3 * _glowController.value),
                          AppColors.accent.withValues(alpha: 0.1 * _glowController.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Animated snake
            AnimatedBuilder(
              animation: _snakeController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: SnakePainter(progress: _snakeController.value),
                );
              },
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Snake emoji with dice
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🐍', style: TextStyle(fontSize: 60))
                          .animate()
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(width: 10),
                      const Text('🎲', style: TextStyle(fontSize: 50))
                          .animate(delay: 200.ms)
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          )
                          .then()
                          .shake(duration: 500.ms, hz: 3),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.secondary, AppColors.accent, AppColors.primary],
                    ).createShader(bounds),
                    child: Text(
                      'SNAKE',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.5, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent, AppColors.secondary],
                    ).createShader(bounds),
                    child: Text(
                      'XTREME',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                  )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.5, end: 0),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.backgroundLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.secondary,
                      ),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                  .animate(delay: 1000.ms)
                  .fadeIn(duration: 400.ms),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Loading...',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  )
                  .animate(delay: 1200.ms)
                  .fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for animated snake
class SnakePainter extends CustomPainter {
  final double progress;

  SnakePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Create a wavy snake path across the screen
    final startX = -100.0;
    final endX = size.width + 100;
    final centerY = size.height * 0.15;
    final amplitude = 30.0;
    
    path.moveTo(startX + (progress * (endX - startX)), centerY);
    
    for (double x = 0; x < 200; x += 5) {
      final actualX = startX + (progress * (endX - startX)) - x;
      final y = centerY + math.sin((x + progress * 360) * math.pi / 30) * amplitude;
      
      if (x == 0) {
        path.moveTo(actualX, y);
      } else {
        path.lineTo(actualX, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw snake head
    final headX = startX + (progress * (endX - startX));
    final headY = centerY + math.sin(progress * 360 * math.pi / 30) * amplitude;
    
    final headPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(headX, headY), 12, headPaint);
  }

  @override
  bool shouldRepaint(covariant SnakePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
