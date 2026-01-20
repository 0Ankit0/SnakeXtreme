import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/animated_background.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController _settings = SettingsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'SETTINGS',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: AnimatedBuilder(
                  animation: _settings,
                  builder: (context, child) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSectionHeader('AUDIO'),
                        
                        // BGM Section
                        _buildSwitchTile(
                          'Background Music',
                          _settings.bgmEnabled,
                          (val) => _settings.setBgmEnabled(val),
                        ),
                        if (_settings.bgmEnabled)
                           _buildSliderTile(
                             _settings.bgmVolume, 
                             (val) => _settings.setBgmVolume(val)
                           ),

                        const Divider(color: Colors.white24, height: 32),

                        // SFX Master
                        _buildSwitchTile(
                          'Sound Effects (Master)',
                          _settings.sfxEnabled,
                          (val) => _settings.setSfxEnabled(val),
                        ),
                        if (_settings.sfxEnabled) ...[
                           _buildSliderTile(
                             _settings.sfxVolume, 
                             (val) => _settings.setSfxVolume(val)
                           ),
                           
                           const SizedBox(height: 16),
                           _buildSectionHeader('SFX CUSTOMIZATION'),
                           
                           _buildSwitchTile(
                             'Dice Rolling',
                             _settings.sfxDice,
                             (val) => _settings.setSfxDice(val),
                           ),
                           _buildSwitchTile(
                             'Snake Gulping',
                             _settings.sfxGulp,
                             (val) => _settings.setSfxGulp(val),
                           ),
                           _buildSwitchTile(
                             'Being Eaten (Crying)',
                             _settings.sfxCry,
                             (val) => _settings.setSfxCry(val),
                           ),
                           _buildSwitchTile(
                             'Walking / Running',
                             _settings.sfxRun,
                             (val) => _settings.setSfxRun(val),
                           ),
                           _buildSwitchTile(
                             'Ladder Climbing',
                             _settings.sfxClimb,
                             (val) => _settings.setSfxClimb(val),
                           ),
                           _buildSwitchTile(
                             'Winning Dance',
                             _settings.sfxDance,
                             (val) => _settings.setSfxDance(val),
                           ),
                        ],

                        const Divider(color: Colors.white24, height: 32),
                        
                        _buildSectionHeader('GAMEPLAY'),
                        // Placeholder for future gameplay settings
                        ListTile(
                          title: Text('Vibration', style: GoogleFonts.outfit(color: Colors.white70)),
                          trailing: Switch(value: true, onChanged: (v){}, activeTrackColor: AppColors.primary),
                        )
                      ],
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: GoogleFonts.pressStart2p(
          fontSize: 12,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title, 
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
  
  Widget _buildSliderTile(double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Icon(Icons.volume_mute, color: Colors.white54, size: 20),
          Expanded(
            child: Slider(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              inactiveColor: Colors.white24,
            ),
          ),
          const Icon(Icons.volume_up, color: Colors.white54, size: 20),
        ],
      ),
    );
  }
}
