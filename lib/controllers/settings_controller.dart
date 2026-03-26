import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SfxPreset { classic, arcade, punchy }

class SettingsController extends ChangeNotifier {
  static final SettingsController _instance = SettingsController._internal();
  factory SettingsController() => _instance;
  SettingsController._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Settings
  bool bgmEnabled = true;
  double bgmVolume = 0.5;
  
  bool sfxEnabled = true;
  double sfxVolume = 1.0;
  
  // Specific SFX Toggles
  bool sfxGulp = true;
  bool sfxDance = true;
  bool sfxCry = true; // Being eaten
  bool sfxRun = true;
  bool sfxDice = true;
  bool sfxClimb = true;

  // Presets per SFX row
  SfxPreset presetDice = SfxPreset.classic;
  SfxPreset presetGulp = SfxPreset.classic;
  SfxPreset presetCry = SfxPreset.classic;
  SfxPreset presetRun = SfxPreset.classic;
  SfxPreset presetClimb = SfxPreset.classic;
  SfxPreset presetDance = SfxPreset.classic;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    bgmEnabled = _prefs.getBool('bgmEnabled') ?? true;
    bgmVolume = _prefs.getDouble('bgmVolume') ?? 0.5;
    
    sfxEnabled = _prefs.getBool('sfxEnabled') ?? true;
    sfxVolume = _prefs.getDouble('sfxVolume') ?? 1.0;
    
    sfxGulp = _prefs.getBool('sfxGulp') ?? true;
    sfxDance = _prefs.getBool('sfxDance') ?? true;
    sfxCry = _prefs.getBool('sfxCry') ?? true;
    sfxRun = _prefs.getBool('sfxRun') ?? true;
    sfxDice = _prefs.getBool('sfxDice') ?? true;
    sfxClimb = _prefs.getBool('sfxClimb') ?? true;

    presetDice = _readPreset('presetDice');
    presetGulp = _readPreset('presetGulp');
    presetCry = _readPreset('presetCry');
    presetRun = _readPreset('presetRun');
    presetClimb = _readPreset('presetClimb');
    presetDance = _readPreset('presetDance');
    
    _initialized = true;
    notifyListeners();
  }

  // Setters with persistence
  Future<void> setBgmEnabled(bool value) async {
    bgmEnabled = value;
    await _prefs.setBool('bgmEnabled', value);
    notifyListeners();
  }

  Future<void> setBgmVolume(double value) async {
    bgmVolume = value;
    await _prefs.setDouble('bgmVolume', value);
    notifyListeners();
  }

  Future<void> setSfxEnabled(bool value) async {
    sfxEnabled = value;
    await _prefs.setBool('sfxEnabled', value);
    notifyListeners();
  }
  
  Future<void> setSfxVolume(double value) async {
    sfxVolume = value;
    await _prefs.setDouble('sfxVolume', value);
    notifyListeners();
  }

  // Specific Toggles
  Future<void> setSfxGulp(bool value) async {
    sfxGulp = value;
    await _prefs.setBool('sfxGulp', value);
    notifyListeners();
  }

  Future<void> setSfxDance(bool value) async {
    sfxDance = value;
    await _prefs.setBool('sfxDance', value);
    notifyListeners();
  }

  Future<void> setSfxCry(bool value) async {
    sfxCry = value;
    await _prefs.setBool('sfxCry', value);
    notifyListeners();
  }

  Future<void> setSfxRun(bool value) async {
    sfxRun = value;
    await _prefs.setBool('sfxRun', value);
    notifyListeners();
  }

  Future<void> setSfxDice(bool value) async {
    sfxDice = value;
    await _prefs.setBool('sfxDice', value);
    notifyListeners();
  }
  
  Future<void> setSfxClimb(bool value) async {
    sfxClimb = value;
    await _prefs.setBool('sfxClimb', value);
    notifyListeners();
  }

  Future<void> setPresetDice(SfxPreset value) async {
    presetDice = value;
    await _prefs.setString('presetDice', value.name);
    notifyListeners();
  }

  Future<void> setPresetGulp(SfxPreset value) async {
    presetGulp = value;
    await _prefs.setString('presetGulp', value.name);
    notifyListeners();
  }

  Future<void> setPresetCry(SfxPreset value) async {
    presetCry = value;
    await _prefs.setString('presetCry', value.name);
    notifyListeners();
  }

  Future<void> setPresetRun(SfxPreset value) async {
    presetRun = value;
    await _prefs.setString('presetRun', value.name);
    notifyListeners();
  }

  Future<void> setPresetClimb(SfxPreset value) async {
    presetClimb = value;
    await _prefs.setString('presetClimb', value.name);
    notifyListeners();
  }

  Future<void> setPresetDance(SfxPreset value) async {
    presetDance = value;
    await _prefs.setString('presetDance', value.name);
    notifyListeners();
  }

  SfxPreset _readPreset(String key) {
    final raw = _prefs.getString(key);
    return SfxPreset.values.firstWhere(
      (preset) => preset.name == raw,
      orElse: () => SfxPreset.classic,
    );
  }
}
