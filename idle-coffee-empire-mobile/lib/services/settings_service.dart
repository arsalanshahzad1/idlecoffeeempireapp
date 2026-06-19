import 'package:hive_flutter/hive_flutter.dart';

import '../models/settings_state.dart';
import '../models/tutorial_state.dart';

class SettingsService {
  SettingsService();

  static const _boxName = 'idle_coffee_settings_box';
  static const _settingsKey = 'settings_state';
  static const _tutorialKey = 'tutorial_state';
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) {
      return;
    }
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    _initialized = true;
  }

  Future<SettingsState> loadSettings() async {
    final box = Hive.box(_boxName);
    final raw = box.get(_settingsKey);
    if (raw is Map) {
      return SettingsState.fromMap(raw);
    }
    return SettingsState.defaults;
  }

  Future<TutorialState> loadTutorial() async {
    final box = Hive.box(_boxName);
    final raw = box.get(_tutorialKey);
    if (raw is Map) {
      return TutorialState.fromMap(raw);
    }
    return TutorialState.initial;
  }

  Future<void> saveSettings(SettingsState settings) async {
    final box = Hive.box(_boxName);
    await box.put(_settingsKey, settings.toMap());
  }

  Future<void> saveTutorial(TutorialState tutorial) async {
    final box = Hive.box(_boxName);
    await box.put(_tutorialKey, tutorial.toMap());
  }

  Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.delete(_settingsKey);
    await box.delete(_tutorialKey);
  }
}
