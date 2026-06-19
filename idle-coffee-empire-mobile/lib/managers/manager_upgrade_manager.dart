import '../data/manager_configs.dart';
import '../features/game/game_state.dart';
import '../models/manager_config.dart';

class ManagerUpgradeManager {
  const ManagerUpgradeManager();

  List<ManagerConfig> get all => managerConfigs;

  ManagerConfig? byId(String id) {
    for (final cfg in managerConfigs) {
      if (cfg.id == id) {
        return cfg;
      }
    }
    return null;
  }

  bool isUnlocked(GameState state, ManagerConfig config) {
    final req = config.unlock;
    final stationReq = req.stationLevel;
    if (stationReq != null) {
      final station = state.stations[stationReq.stationId];
      if (station == null || station.level < stationReq.level) {
        return false;
      }
    }
    if (req.expansionStageId != null && state.expansionStageId != req.expansionStageId) {
      return false;
    }
    if (req.playerLevel != null && state.playerLevel < req.playerLevel!) {
      return false;
    }
    return true;
  }

  double stationSpeedMultiplier(GameState state, String stationId) {
    var boost = 0.0;
    for (final id in state.purchasedManagerIds) {
      final cfg = byId(id);
      if (cfg == null) {
        continue;
      }
      boost += cfg.effect.stationSpeedBoostByStation[stationId] ?? 0;
    }
    return 1 + boost;
  }

  double globalIncomeMultiplier(GameState state) {
    var boost = 0.0;
    for (final id in state.purchasedManagerIds) {
      final cfg = byId(id);
      if (cfg == null) {
        continue;
      }
      boost += cfg.effect.globalIncomeBoost;
    }
    return 1 + boost;
  }

  double customerSpawnRateMultiplier(GameState state) {
    var boost = 0.0;
    for (final id in state.purchasedManagerIds) {
      final cfg = byId(id);
      if (cfg == null) {
        continue;
      }
      boost += cfg.effect.customerSpawnRateBoost;
    }
    return 1 + boost;
  }
}
