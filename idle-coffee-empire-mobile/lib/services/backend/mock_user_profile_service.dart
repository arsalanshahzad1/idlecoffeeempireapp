import 'package:hive_flutter/hive_flutter.dart';

import '../../models/player_profile.dart';
import 'user_profile_service.dart';

class MockUserProfileService implements UserProfileService {
  static const String _boxName = 'idle_coffee_profile_box';
  static const String _profileKey = 'player_profile';
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

  @override
  Future<PlayerProfile> loadOrCreateProfile() async {
    await init();
    final box = Hive.box(_boxName);
    final raw = box.get(_profileKey);
    if (raw is Map) {
      return PlayerProfile.fromMap(raw);
    }
    final created = PlayerProfile.createDefault();
    await saveProfile(created);
    return created;
  }

  @override
  Future<void> saveProfile(PlayerProfile profile) async {
    await init();
    final box = Hive.box(_boxName);
    await box.put(_profileKey, profile.toMap());
  }
}
