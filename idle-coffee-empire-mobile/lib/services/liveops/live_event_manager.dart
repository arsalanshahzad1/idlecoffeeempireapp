import 'live_event_model.dart';

abstract class LiveEventManager {
  Future<List<LiveEventModel>> getActiveEvents();
  Future<void> simulateEvent(LiveEventModel event);
}
