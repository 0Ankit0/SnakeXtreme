import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/animated_background.dart';
import '../controllers/settings_controller.dart';
import '../services/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController _settings = SettingsController();
  final Set<SfxType> _expandedRows = <SfxType>{};

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

                           _buildPresetRow(
                             title: 'Dice Rolling',
                             type: SfxType.diceRoll,
                             enabled: _settings.sfxDice,
                             onEnabled: _settings.setSfxDice,
                             selectedPreset: _settings.presetDice,
                             onPreset: _settings.setPresetDice,
                           ),
                           _buildPresetRow(
                             title: 'Snake Gulping',
                             type: SfxType.gulp,
                             enabled: _settings.sfxGulp,
                             onEnabled: _settings.setSfxGulp,
                             selectedPreset: _settings.presetGulp,
                             onPreset: _settings.setPresetGulp,
                           ),
                           _buildPresetRow(
                             title: 'Being Eaten',
                             type: SfxType.slide,
                             enabled: _settings.sfxCry,
                             onEnabled: _settings.setSfxCry,
                             selectedPreset: _settings.presetCry,
                             onPreset: _settings.setPresetCry,
                           ),
                           _buildPresetRow(
                             title: 'Walking / Running',
                             type: SfxType.step,
                             enabled: _settings.sfxRun,
                             onEnabled: _settings.setSfxRun,
                             selectedPreset: _settings.presetRun,
                             onPreset: _settings.setPresetRun,
                           ),
                           _buildPresetRow(
                             title: 'Ladder Climbing',
                             type: SfxType.climb,
                             enabled: _settings.sfxClimb,
                             onEnabled: _settings.setSfxClimb,
                             selectedPreset: _settings.presetClimb,
                             onPreset: _settings.setPresetClimb,
                           ),
                           _buildPresetRow(
                             title: 'Winning Dance',
                             type: SfxType.win,
                             enabled: _settings.sfxDance,
                             onEnabled: _settings.setSfxDance,
                             selectedPreset: _settings.presetDance,
                             onPreset: _settings.setPresetDance,
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

  Widget _buildPresetRow({
    required String title,
    required SfxType type,
    required bool enabled,
    required Future<void> Function(bool) onEnabled,
    required SfxPreset selectedPreset,
    required Future<void> Function(SfxPreset) onPreset,
  }) {
    final canCustomize = _settings.sfxEnabled && enabled;
    final expanded = _expandedRows.contains(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: enabled,
                  onChanged: onEnabled,
                  activeTrackColor: AppColors.primary,
                ),
                IconButton(
                  onPressed: canCustomize
                      ? () {
                          setState(() {
                            if (expanded) {
                              _expandedRows.remove(type);
                            } else {
                              _expandedRows.add(type);
                            }
                          });
                        }
                      : null,
                  icon: Icon(expanded ? Icons.expand_less : Icons.expand_more, color: Colors.white),
                ),
              ],
            ),
          ),
          if (canCustomize && expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<SfxPreset>(
                      value: selectedPreset,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Preset',
                      ),
                      dropdownColor: AppColors.backgroundDark,
                      style: GoogleFonts.outfit(color: Colors.white),
                      items: SfxPreset.values.map((preset) {
                        return DropdownMenuItem(
                          value: preset,
                          child: Text(_presetLabel(preset)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) onPreset(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => AudioManager().previewSfx(type),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Preview'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _presetLabel(SfxPreset preset) {
    switch (preset) {
      case SfxPreset.classic:
        return 'Classic';
      case SfxPreset.arcade:
        return 'Arcade';
      case SfxPreset.punchy:
        return 'Punchy';
    }
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
