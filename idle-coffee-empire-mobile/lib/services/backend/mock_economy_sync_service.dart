import '../../features/game/game_state.dart';
import 'economy_sync_service.dart';

class MockEconomySyncService implements EconomySyncService {
  final List<Map<String, Object>> _queued = <Map<String, Object>>[];

  @override
  Future<void> flushQueuedSnapshots() async {
    // TODO(backend): send batched snapshots to backend endpoint.
    _queued.clear();
  }

  @override
  Future<void> queueSnapshot(GameState state) async {
    _queued.add(<String, Object>{
      'coins': state.coins,
      'gems': state.gems,
      'prestigePoints': state.prestigePoints,
      'savedAt': state.lastSavedAtUtcMillis,
    });
  }

  @override
  int queuedCount() {
    return _queued.length;
  }
}
