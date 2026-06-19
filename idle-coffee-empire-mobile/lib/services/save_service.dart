import 'package:hive_flutter/hive_flutter.dart';

import '../models/game_save_data.dart';
import 'save_migration.dart';

class SaveLoadResult {
  const SaveLoadResult({
    required this.data,
    required this.corrupted,
  });

  final GameSaveData? data;
  final bool corrupted;
}

class SaveService {
  SaveService();

  static const _boxName = 'idle_coffee_save_box';
  static const _saveKey = 'game_save_data';
  static const _backupSaveKey = 'game_save_data_backup';
  static bool _initialized = false;
  final SaveMigration _migration = const SaveMigration();

  static Future<void> init() async {
    if (_initialized) {
      return;
    }
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    _initialized = true;
  }

  Future<SaveLoadResult> load() async {
    final box = Hive.box(_boxName);
    try {
      final primary = _readAndValidate(box.get(_saveKey));
      if (primary != null) {
        return SaveLoadResult(data: primary, corrupted: false);
      }
      final backup = _readAndValidate(box.get(_backupSaveKey));
      if (backup != null) {
        return SaveLoadResult(data: backup, corrupted: true);
      }
    } catch (_) {
      return const SaveLoadResult(data: null, corrupted: true);
    }
    return const SaveLoadResult(data: null, corrupted: false);
  }

  Future<void> save(GameSaveData data) async {
    final box = Hive.box(_boxName);
    final payload = data.toMap();
    await box.put(_backupSaveKey, payload);
    await box.put(_saveKey, payload);
  }

  Future<void> clear() async {
    final box = Hive.box(_boxName);
    await box.delete(_saveKey);
    await box.delete(_backupSaveKey);
  }

  GameSaveData? _readAndValidate(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final migrated = _migration.migrate(raw);
    if (!_isLikelyValidPayload(migrated)) {
      return null;
    }
    return GameSaveData.fromMap(migrated);
  }

  bool _isLikelyValidPayload(Map<dynamic, dynamic> map) {
    final coins = map['coins'];
    final stations = map['stations'];
    if (coins is! num || coins.isNaN || coins.isInfinite) {
      return false;
    }
    if (stations is! Map) {
      return false;
    }
    return true;
  }
}
