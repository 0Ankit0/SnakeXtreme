import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/menu_button.dart';
import 'game_setup_screen.dart';
import 'settings_screen.dart';
import 'map_editor_screen.dart';

/// Main menu screen with Play, Settings, and Custom Map options
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          
                          // Title
                          _buildTitle(),
                          
                          const Spacer(),
                          
                          // Menu buttons
                          _buildMenuButtons(context),
                          
                          const Spacer(),
                          
                          // Footer
                          _buildFooter(),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Snake emoji header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐍', style: TextStyle(fontSize: 40))
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.5, end: 0),
            const SizedBox(width: 16),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.secondary, AppColors.accent],
              ).createShader(bounds),
              child: Text(
                'SNAKE',
                style: GoogleFonts.pressStart2p(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text('🎲', style: TextStyle(fontSize: 40))
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.5, end: 0),
          ],
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms),
        
        const SizedBox(height: 8),
        
        // XTREME title with glow
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, AppColors.accent, AppColors.secondary],
            ).createShader(bounds),
            child: Text(
              'XTREME',
              style: GoogleFonts.pressStart2p(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        
        const SizedBox(height: 16),
        
        // Tagline
        Text(
          'The Ultimate Snake & Ladder Experience',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        )
        .animate(delay: 600.ms)
        .fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        MenuButton(
          text: 'PLAY',
          icon: Icons.play_arrow_rounded,
          animationDelay: 800,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const GameSetupScreen()),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        MenuButton(
          text: 'SETTINGS',
          icon: Icons.settings_rounded,
          animationDelay: 1000,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        MenuButton(
          text: 'CUSTOM MAP',
          icon: Icons.map_rounded,
          animationDelay: 1200,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MapEditorScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Decorative line
        Container(
          width: 100,
          height: 2,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.accent,
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        )
        .animate(delay: 1400.ms)
        .fadeIn(duration: 500.ms)
        .scaleX(begin: 0, end: 1),
        
        const SizedBox(height: 16),
        
        // Version text
        Text(
          'v1.0.0',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        )
        .animate(delay: 1600.ms)
        .fadeIn(duration: 400.ms),
      ],
    );
  }



}
