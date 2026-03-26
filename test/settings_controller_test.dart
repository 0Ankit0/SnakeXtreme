import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_xtreme/controllers/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('settings presets persist and reload', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsController();
    await settings.init();

    await settings.setPresetDice(SfxPreset.arcade);
    await settings.setPresetGulp(SfxPreset.punchy);
    await settings.setPresetRun(SfxPreset.arcade);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('presetDice'), 'arcade');
    expect(prefs.getString('presetGulp'), 'punchy');
    expect(prefs.getString('presetRun'), 'arcade');
  });
}
