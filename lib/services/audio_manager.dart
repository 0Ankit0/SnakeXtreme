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

  final Map<SfxType, String> _sfxFiles = {
    SfxType.buttonClick: 'audio/button_click.mp3',
    SfxType.diceRoll: 'audio/dice_roll.mp3',
    SfxType.step: 'audio/step.mp3',
    SfxType.climb: 'audio/climb.mp3',
    SfxType.slide: 'audio/slide.mp3',
    SfxType.gulp: 'audio/gulp.mp3',
    SfxType.win: 'audio/win.mp3',
  };
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
    if (!_settings.sfxEnabled) return;
    
    // Check specific toggles
    bool allowed = true;
    switch (type) {
      case SfxType.diceRoll: allowed = _settings.sfxDice; break;
      case SfxType.step: allowed = _settings.sfxRun; break;
      case SfxType.climb: allowed = _settings.sfxClimb; break;
      case SfxType.slide: allowed = _settings.sfxCry; break;
      case SfxType.gulp: allowed = _settings.sfxGulp; break;
      case SfxType.win: allowed = _settings.sfxDance; break;
      default: allowed = true;
    }
    
    if (!allowed) return;

    try {
      // Create a temporary player for overlapping sounds if needed, 
      // but for simplicity using shared. Or creates new one for overlapping?
      // AudioPlayer() is lightweight? 
      // Let's use the shared _sfxPlayer for now to prevent spam, 
      // EXCEPT for steps which might need to be frequent.
      
      // Actually, for a game, `stop()` then `play()` cuts off the previous sound.
      // Good for cutting off a long "slide" if new event happens, but bad for "step step step".
      // Let's use a "fire and forget" mode where we make a new player for each SFX 
      // and dispose it on complete? 
      // AudioPlayers has `AudioCache` (now implicit).
      // `AudioPlayer().play` is standard.
      
      final player = AudioPlayer();
      await player.setVolume(_settings.sfxVolume);
      // Play and dispose automatically? 
      // We need to listen to complete.
      
      player.onPlayerComplete.listen((event) { 
        player.dispose();
      });
      
      if (kIsWeb) {
        await player.play(BytesSource(_webSfxBytes(type)));
      } else {
        final path = _sfxFiles[type];
        if (path != null) {
          await player.play(AssetSource(path));
        }
      }
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }

  Uint8List _webSfxBytes(SfxType type) {
    switch (type) {
      case SfxType.buttonClick:
        return _getOrCreateWebAudio('buttonClick', () => _createWaveBytes(durationSeconds: 0.08, frequencies: const [1200, 1600], volume: 0.40));
      case SfxType.diceRoll:
        return _getOrCreateWebAudio('diceRoll', () => _createWaveBytes(durationSeconds: 0.55, frequencies: const [300, 900], volume: 0.38, sweep: true));
      case SfxType.step:
        return _getOrCreateWebAudio('step', () => _createWaveBytes(durationSeconds: 0.09, frequencies: const [220, 280], volume: 0.45));
      case SfxType.climb:
        return _getOrCreateWebAudio('climb', () => _createWaveBytes(durationSeconds: 0.35, frequencies: const [440, 660], volume: 0.35, sweep: true));
      case SfxType.slide:
        return _getOrCreateWebAudio('slide', () => _createWaveBytes(durationSeconds: 0.45, frequencies: const [880, 220], volume: 0.35, sweep: true));
      case SfxType.gulp:
        return _getOrCreateWebAudio('gulp', () => _createWaveBytes(durationSeconds: 0.20, frequencies: const [180, 120], volume: 0.45, sweep: true));
      case SfxType.win:
        return _getOrCreateWebAudio('win', () => _createWaveBytes(durationSeconds: 0.80, frequencies: const [523, 659, 784], volume: 0.30));
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
