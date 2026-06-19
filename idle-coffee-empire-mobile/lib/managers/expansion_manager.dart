import '../data/expansion_configs.dart';
import '../features/game/game_state.dart';
import '../models/expansion_config.dart';

class ExpansionManager {
  const ExpansionManager();

  List<ExpansionConfig> get all => expansionConfigs;

  ExpansionConfig byId(String id) {
    for (final cfg in expansionConfigs) {
      if (cfg.id == id) {
        return cfg;
      }
    }
    return expansionConfigs.first;
  }

  ExpansionConfig currentForState(GameState state) {
    var current = expansionConfigs.first;
    for (final cfg in expansionConfigs) {
      if (_meetsRequirements(state, cfg)) {
        current = cfg;
      }
    }
    return current;
  }

  bool _meetsRequirements(GameState state, ExpansionConfig cfg) {
    if (state.lifetimeCoinsEarned < cfg.minLifetimeCoinsEarned) {
      return false;
    }
    if (state.lifetimeCustomersServed < cfg.minCustomersServed) {
      return false;
    }
    for (final entry in cfg.minStationLevels.entries) {
      final station = state.stations[entry.key];
      if (station == null || station.level < entry.value) {
        return false;
      }
    }
    return true;
  }
}
