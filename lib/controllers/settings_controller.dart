import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
