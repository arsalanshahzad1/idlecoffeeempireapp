import '../../models/game_save_data.dart';
import 'cloud_save_service.dart';
import 'sync_models.dart';

class MockCloudSaveService implements CloudSaveService {
  GameSaveData? _remoteSave;
  CloudSyncState _syncState = CloudSyncState.initial();

  @override
  Future<CloudSyncState> getSyncState() async {
    return _syncState;
  }

  @override
  Future<GameSaveData?> pullRemoteSave() async {
    return _remoteSave;
  }

  @override
  Future<void> pushLocalSave(GameSaveData saveData) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    _remoteSave = saveData;
    _syncState = _syncState.copyWith(
      localSaveTimestampUtcMillis: now,
      remoteSaveTimestampUtcMillis: now,
      lastSyncStatus: 'mock_push_ok',
    );
  }

  @override
  Future<CloudSyncState> simulateSync() async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    _syncState = _syncState.copyWith(
      localSaveTimestampUtcMillis: now,
      remoteSaveTimestampUtcMillis: now,
      syncVersion: _syncState.syncVersion + 1,
      lastSyncStatus: 'mock_sync_ok',
    );
    return _syncState;
  }
}
