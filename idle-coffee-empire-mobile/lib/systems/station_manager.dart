import '../data/station_configs.dart';
import '../models/station_state.dart';

class StationManager {
  const StationManager();

  Map<String, StationState> createDefaultStates() {
    final map = <String, StationState>{};
    for (final config in stationConfigs) {
      map[config.id] = StationState(
        stationId: config.id,
        level: 1,
        isUnlocked: config.unlockCost == 0,
        autoEnabled: config.unlockCost == 0,
      );
    }
    return map;
  }
}
