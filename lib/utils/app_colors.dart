import 'package:flutter/material.dart';

/// App color scheme for SnakeXtreme
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6B46C1);       // Deep Purple
  static const Color secondary = Color(0xFF10B981);     // Neon Green
  static const Color accent = Color(0xFF3B82F6);        // Electric Blue
  
  // Background gradient colors
  static const Color backgroundDark = Color(0xFF0F0F23);
  static const Color backgroundLight = Color(0xFF1A1A2E);
  static const Color backgroundMid = Color(0xFF16162A);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  
  // Button colors
  static const Color buttonGlow = Color(0xFF8B5CF6);    // Purple glow
  static const Color buttonBorder = Color(0xFF4C1D95);
  
  // Snake and ladder colors
  static const Color snakeColor = Color(0xFFEF4444);    // Red
  static const Color ladderColor = Color(0xFFFBBF24);   // Yellow/Gold
  
  // Gradient presets
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark, backgroundMid, backgroundLight],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
  
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, accent, primary],
  );
}
