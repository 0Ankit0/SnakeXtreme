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
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
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
      
      final path = _sfxFiles[type];
      if (path != null) {
        await player.play(AssetSource(path));
      }
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }
}


