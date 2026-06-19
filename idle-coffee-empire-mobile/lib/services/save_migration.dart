import '../models/game_save_data.dart';

class SaveMigration {
  const SaveMigration();

  Map<dynamic, dynamic> migrate(Map<dynamic, dynamic> raw) {
    final source = Map<dynamic, dynamic>.from(raw);
    final version = (source['saveVersion'] as num?)?.toInt() ?? 1;
    var migrated = source;
    if (version < 4) {
      migrated = _migratePreV4(migrated);
    }
    if ((migrated['saveVersion'] as num?)?.toInt() != GameSaveData.currentSaveVersion) {
      migrated['saveVersion'] = GameSaveData.currentSaveVersion;
    }
    migrated.putIfAbsent(
      'lastSavedAtUtcMillis',
      () => DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    migrated.putIfAbsent('cafeOrders', () => <dynamic>[]);
    migrated.putIfAbsent('stationQueues', () => <String, dynamic>{});
    migrated.putIfAbsent('cafeTables', () => <dynamic>[]);
    migrated.putIfAbsent('tipsEarned', () => 0);
    migrated.putIfAbsent('tipsReceived', () => 0);
    migrated.putIfAbsent('satisfiedOrders', () => 0);
    migrated.putIfAbsent('failedOrders', () => 0);
    migrated.putIfAbsent('nextOrderSerial', () => 1);
    return migrated;
  }

  Map<dynamic, dynamic> _migratePreV4(Map<dynamic, dynamic> input) {
    final next = Map<dynamic, dynamic>.from(input);
    next.putIfAbsent('resources', () => <String, dynamic>{});
    next.putIfAbsent('activeBoosts', () => <String, dynamic>{});
    return next;
  }
}
