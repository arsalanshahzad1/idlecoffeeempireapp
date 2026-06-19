import '../data/permanent_upgrade_configs.dart';
import '../models/permanent_upgrade_config.dart';
import '../models/permanent_upgrade_state.dart';

class PermanentUpgradeManager {
  const PermanentUpgradeManager();

  List<PermanentUpgradeConfig> get all => permanentUpgradeConfigs;

  PermanentUpgradeConfig? byId(String id) {
    for (final cfg in permanentUpgradeConfigs) {
      if (cfg.id == id) {
        return cfg;
      }
    }
    return null;
  }

  List<PermanentUpgradeState> buildStates(Set<String> purchasedUpgradeIds) {
    return permanentUpgradeConfigs
        .map(
          (config) => PermanentUpgradeState(
            config: config,
            owned: purchasedUpgradeIds.contains(config.id),
          ),
        )
        .toList(growable: false);
  }

  double _totalBoost(
    Set<String> purchasedUpgradeIds,
    PermanentUpgradeEffectType effectType,
  ) {
    var total = 0.0;
    for (final cfg in permanentUpgradeConfigs) {
      if (cfg.effectType == effectType && purchasedUpgradeIds.contains(cfg.id)) {
        total += cfg.effectValue;
      }
    }
    return total;
  }

  double stationSpeedMultiplier(Set<String> purchasedUpgradeIds) {
    return 1.0 +
        _totalBoost(
          purchasedUpgradeIds,
          PermanentUpgradeEffectType.stationProductionSpeedBoost,
        );
  }

  double customerRewardMultiplier(Set<String> purchasedUpgradeIds) {
    return 1.0 +
        _totalBoost(
          purchasedUpgradeIds,
          PermanentUpgradeEffectType.customerRewardBoost,
        );
  }

  double workerEfficiencyMultiplier(Set<String> purchasedUpgradeIds) {
    return 1.0 +
        _totalBoost(
          purchasedUpgradeIds,
          PermanentUpgradeEffectType.workerEfficiencyBoost,
        );
  }

  double customerSpawnRateMultiplier(Set<String> purchasedUpgradeIds) {
    return 1.0 +
        _totalBoost(
          purchasedUpgradeIds,
          PermanentUpgradeEffectType.customerSpawnRateBoost,
        );
  }
}
