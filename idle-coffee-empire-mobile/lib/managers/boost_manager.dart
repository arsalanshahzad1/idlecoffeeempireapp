import '../data/monetization_config.dart';
import '../models/boost_state.dart';

class BoostManager {
  const BoostManager();

  List<BoostConfig> get all => MonetizationConfig.boosts;

  BoostConfig? byId(String id) {
    for (final cfg in all) {
      if (cfg.id == id) {
        return cfg;
      }
    }
    return null;
  }

  Map<String, BoostState> sanitize(
    Map<String, BoostState> boosts,
    DateTime nowUtc,
  ) {
    final next = <String, BoostState>{};
    for (final entry in boosts.entries) {
      if (entry.value.boostId.isEmpty) {
        continue;
      }
      if (!entry.value.isActiveAt(nowUtc)) {
        continue;
      }
      if (byId(entry.key) == null) {
        continue;
      }
      next[entry.key] = entry.value;
    }
    return next;
  }

  Map<String, BoostState> activate({
    required Map<String, BoostState> existing,
    required BoostConfig config,
    required DateTime nowUtc,
  }) {
    final next = Map<String, BoostState>.from(existing);
    next[config.id] = BoostState(
      boostId: config.id,
      expiresAtUtcMillis: nowUtc.millisecondsSinceEpoch + (config.durationSeconds * 1000),
    );
    return next;
  }

  double activeIncomeMultiplier(Map<String, BoostState> boosts, DateTime nowUtc) {
    var mult = 1.0;
    for (final cfg in all) {
      final state = boosts[cfg.id];
      if (state != null && state.isActiveAt(nowUtc)) {
        mult *= cfg.incomeMultiplier;
      }
    }
    return mult;
  }

  double activeProductionSpeedMultiplier(
    Map<String, BoostState> boosts,
    DateTime nowUtc,
  ) {
    var mult = 1.0;
    for (final cfg in all) {
      final state = boosts[cfg.id];
      if (state != null && state.isActiveAt(nowUtc)) {
        mult *= cfg.productionSpeedMultiplier;
      }
    }
    return mult;
  }

  double activeSpawnRateMultiplier(Map<String, BoostState> boosts, DateTime nowUtc) {
    var mult = 1.0;
    for (final cfg in all) {
      final state = boosts[cfg.id];
      if (state != null && state.isActiveAt(nowUtc)) {
        mult *= cfg.spawnRateMultiplier;
      }
    }
    return mult;
  }
}
