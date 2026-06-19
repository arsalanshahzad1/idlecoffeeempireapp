import '../data/decoration_configs.dart';
import '../models/decoration_config.dart';

class DecorationManager {
  const DecorationManager();

  List<DecorationConfig> get all => decorationConfigs;

  DecorationConfig byId(String id) {
    for (final cfg in decorationConfigs) {
      if (cfg.id == id) {
        return cfg;
      }
    }
    return decorationConfigs.first;
  }

  double incomeMultiplier(Set<String> purchased) {
    var value = 1.0;
    for (final cfg in decorationConfigs) {
      if (purchased.contains(cfg.id)) {
        value *= cfg.incomeMultiplier;
      }
    }
    return value;
  }

  double spawnRateMultiplier(Set<String> purchased) {
    var value = 1.0;
    for (final cfg in decorationConfigs) {
      if (purchased.contains(cfg.id)) {
        value *= cfg.spawnRateMultiplier;
      }
    }
    return value;
  }

  int queueCapacityBonus(Set<String> purchased) {
    var value = 0;
    for (final cfg in decorationConfigs) {
      if (purchased.contains(cfg.id)) {
        value += cfg.queueCapacityBonus;
      }
    }
    return value;
  }
}
