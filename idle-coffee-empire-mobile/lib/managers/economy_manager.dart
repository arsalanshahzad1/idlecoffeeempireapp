import 'dart:math' as math;

import '../data/economy_balance_config.dart';
import '../models/station_config.dart';
import '../models/station_state.dart';

class EconomyManager {
  const EconomyManager();

  double upgradeCost(StationConfig config, int level) {
    return config.baseUpgradeCost *
        math.pow(level, EconomyBalanceConfig.stationUpgradeCostExponent);
  }

  double profitPerTap(StationConfig config, StationState state) {
    return config.baseProfit * state.level;
  }

  double coinsPerSecond(StationConfig config, StationState state) {
    if (!state.isUnlocked || !state.autoEnabled) {
      return 0;
    }
    return profitPerTap(config, state) / config.productionTimeSeconds;
  }
}
