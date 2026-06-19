import '../../features/game/game_state.dart';

abstract class EconomySyncService {
  Future<void> queueSnapshot(GameState state);
  Future<void> flushQueuedSnapshots();
  int queuedCount();
}
