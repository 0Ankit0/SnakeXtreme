import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_colors.dart';

/// Glassmorphism styled menu button with animations
class MenuButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final int animationDelay;

  const MenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            // Glassmorphism effect
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _isPressed ? 0.5 : 0.3),
                blurRadius: _isPressed ? 20 : 15,
                spreadRadius: _isPressed ? 2 : 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with gradient
              ShaderMask(
                shaderCallback: (bounds) => AppColors.neonGradient.createShader(bounds),
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate(delay: Duration(milliseconds: widget.animationDelay))
    .fadeIn(duration: 500.ms)
    .slideX(begin: -0.3, end: 0, curve: Curves.easeOutBack);
  }
}
