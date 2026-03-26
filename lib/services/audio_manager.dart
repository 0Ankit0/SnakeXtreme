import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../controllers/settings_controller.dart';

enum SfxType {
  buttonClick,
  diceRoll,
  step,
  climb,
  slide, // Being eaten / cry
  gulp,  // Snake eating
  win,   // Dance
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  // Cache settings
  final SettingsController _settings = SettingsController();

  final Map<String, Uint8List> _webAudioCache = {};

  void init() {
    _settings.addListener(_updateSettings);
    // Be careful relying on settings listeners if init order matters
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }
  
  void _updateSettings() {
    if (_settings.bgmEnabled) {
      if (_bgmPlayer.state != PlayerState.playing) {
        playBgm();
      }
      _bgmPlayer.setVolume(_settings.bgmVolume);
    } else {
      _bgmPlayer.stop();
    }
  }

  Future<void> playBgm() async {
    if (!_settings.bgmEnabled) return;
    try {
      await _bgmPlayer.setVolume(_settings.bgmVolume);
      if (kIsWeb) {
        await _bgmPlayer.play(BytesSource(_getOrCreateWebAudio('bgm', () {
          return _createWaveBytes(
            durationSeconds: 2.4,
            frequencies: const [261.63, 329.63, 392.0, 523.25],
            volume: 0.22,
            arpeggio: true,
          );
        })));
      } else {
        await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
      }
    } catch (e) {
      debugPrint('Error playing BGM: $e');
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> playSfx(SfxType type) async {
    if (!_isTypeEnabled(type)) return;
    await _playPreset(type, _presetForType(type));
  }

  Future<void> previewSfx(SfxType type) async {
    if (!_isTypeEnabled(type)) return;
    await _playPreset(type, _presetForType(type));
  }

  bool _isTypeEnabled(SfxType type) {
    if (!_settings.sfxEnabled) return false;
    switch (type) {
      case SfxType.diceRoll:
        return _settings.sfxDice;
      case SfxType.step:
        return _settings.sfxRun;
      case SfxType.climb:
        return _settings.sfxClimb;
      case SfxType.slide:
        return _settings.sfxCry;
      case SfxType.gulp:
        return _settings.sfxGulp;
      case SfxType.win:
        return _settings.sfxDance;
      case SfxType.buttonClick:
        return true;
    }
  }

  SfxPreset _presetForType(SfxType type) {
    switch (type) {
      case SfxType.diceRoll:
        return _settings.presetDice;
      case SfxType.step:
        return _settings.presetRun;
      case SfxType.climb:
        return _settings.presetClimb;
      case SfxType.slide:
        return _settings.presetCry;
      case SfxType.gulp:
        return _settings.presetGulp;
      case SfxType.win:
        return _settings.presetDance;
      case SfxType.buttonClick:
        return SfxPreset.classic;
    }
  }

  Future<void> _playPreset(SfxType type, SfxPreset preset) async {
    final recipe = _recipeFor(type, preset);

    try {
      final player = AudioPlayer();
      await player.setVolume(_settings.sfxVolume);
      player.onPlayerComplete.listen((event) {
        player.dispose();
      });
      await player.play(
        BytesSource(
          _getOrCreateWebAudio('${type.name}_${preset.name}', () {
            return _createWaveBytes(
              durationSeconds: recipe.duration,
              frequencies: recipe.frequencies,
              volume: recipe.volume,
              sweep: recipe.sweep,
              arpeggio: recipe.arpeggio,
            );
          }),
        ),
      );
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }

  _SfxRecipe _recipeFor(SfxType type, SfxPreset preset) {
    switch (preset) {
      case SfxPreset.classic:
        switch (type) {
          case SfxType.buttonClick:
            return const _SfxRecipe([1200, 1600], 0.08, 0.40);
          case SfxType.diceRoll:
            return const _SfxRecipe([280, 860], 0.55, 0.35, sweep: true);
          case SfxType.step:
            return const _SfxRecipe([220, 280], 0.10, 0.45);
          case SfxType.climb:
            return const _SfxRecipe([380, 620], 0.30, 0.35, sweep: true);
          case SfxType.slide:
            return const _SfxRecipe([980, 240], 0.45, 0.34, sweep: true);
          case SfxType.gulp:
            return const _SfxRecipe([180, 120], 0.20, 0.48, sweep: true);
          case SfxType.win:
            return const _SfxRecipe([523, 659, 784], 0.80, 0.30, arpeggio: true);
        }
      case SfxPreset.arcade:
        switch (type) {
          case SfxType.buttonClick:
            return const _SfxRecipe([1500, 1800], 0.07, 0.36);
          case SfxType.diceRoll:
            return const _SfxRecipe([440, 1020], 0.50, 0.34, sweep: true);
          case SfxType.step:
            return const _SfxRecipe([280, 340], 0.08, 0.40);
          case SfxType.climb:
            return const _SfxRecipe([440, 740], 0.28, 0.32, sweep: true);
          case SfxType.slide:
            return const _SfxRecipe([1200, 280], 0.40, 0.33, sweep: true);
          case SfxType.gulp:
            return const _SfxRecipe([220, 140], 0.18, 0.45, sweep: true);
          case SfxType.win:
            return const _SfxRecipe([659, 784, 1046], 0.72, 0.28, arpeggio: true);
        }
      case SfxPreset.punchy:
        switch (type) {
          case SfxType.buttonClick:
            return const _SfxRecipe([900, 1400], 0.06, 0.46);
          case SfxType.diceRoll:
            return const _SfxRecipe([210, 740], 0.44, 0.42, sweep: true);
          case SfxType.step:
            return const _SfxRecipe([160, 250], 0.07, 0.52);
          case SfxType.climb:
            return const _SfxRecipe([300, 520], 0.22, 0.42, sweep: true);
          case SfxType.slide:
            return const _SfxRecipe([780, 180], 0.36, 0.41, sweep: true);
          case SfxType.gulp:
            return const _SfxRecipe([140, 96], 0.16, 0.58, sweep: true);
          case SfxType.win:
            return const _SfxRecipe([784, 988, 1174], 0.60, 0.35, arpeggio: true);
        }
    }
  }

  Uint8List _getOrCreateWebAudio(String key, Uint8List Function() create) {
    return _webAudioCache.putIfAbsent(key, create);
  }

  Uint8List _createWaveBytes({
    required double durationSeconds,
    required List<double> frequencies,
    required double volume,
    bool sweep = false,
    bool arpeggio = false,
  }) {
    const sampleRate = 44100;
    final totalSamples = (sampleRate * durationSeconds).round();
    final pcmBytes = ByteData(totalSamples * 2);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final position = i / totalSamples;

      final attack = 0.02;
      final release = 0.08;
      final envelope = position < attack
          ? position / attack
          : (position > 1 - release ? (1 - position) / release : 1.0);

      double sample;
      if (arpeggio && frequencies.isNotEmpty) {
        final idx = (((t * 2) * 2).floor()) % frequencies.length;
        final f = frequencies[idx];
        sample = (0.6 * math.sin(2 * math.pi * f * t)) + (0.3 * math.sin(2 * math.pi * (f / 2) * t));
      } else if (sweep && frequencies.length >= 2) {
        final start = frequencies.first;
        final end = frequencies.last;
        final f = start + ((end - start) * position);
        sample = math.sin(2 * math.pi * f * t);
      } else {
        sample = 0;
        for (final f in frequencies) {
          sample += math.sin(2 * math.pi * f * t);
        }
        sample /= frequencies.isEmpty ? 1 : frequencies.length;
      }

      final value = (sample * envelope * volume).clamp(-1.0, 1.0);
      pcmBytes.setInt16(i * 2, (value * 32767).round(), Endian.little);
    }

    final bytes = ByteData(44 + (totalSamples * 2));
    void writeAscii(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        bytes.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    bytes.setUint32(4, 36 + (totalSamples * 2), Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little); // PCM chunk size
    bytes.setUint16(20, 1, Endian.little); // PCM format
    bytes.setUint16(22, 1, Endian.little); // mono
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    bytes.setUint16(32, 2, Endian.little); // block align
    bytes.setUint16(34, 16, Endian.little); // bits/sample
    writeAscii(36, 'data');
    bytes.setUint32(40, totalSamples * 2, Endian.little);

    for (int i = 0; i < totalSamples * 2; i++) {
      bytes.setUint8(44 + i, pcmBytes.getUint8(i));
    }

    return bytes.buffer.asUint8List();
  }
}

class _SfxRecipe {
  final List<double> frequencies;
  final double duration;
  final double volume;
  final bool sweep;
  final bool arpeggio;

  const _SfxRecipe(
    this.frequencies,
    this.duration,
    this.volume, {
    this.sweep = false,
    this.arpeggio = false,
  });
}
