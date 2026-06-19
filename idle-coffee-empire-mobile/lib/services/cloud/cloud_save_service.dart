import '../../models/game_save_data.dart';
import 'sync_models.dart';

abstract class CloudSaveService {
  Future<CloudSyncState> getSyncState();
  Future<void> pushLocalSave(GameSaveData saveData);
  Future<GameSaveData?> pullRemoteSave();
  Future<CloudSyncState> simulateSync();
}
