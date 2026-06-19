import '../data/station_milestone_bonus_configs.dart';
import '../models/station_milestone_bonus.dart';

class StationBonusManager {
  const StationBonusManager();

  List<StationMilestoneBonus> bonusesForStation(String stationId) {
    return stationMilestoneBonusConfigs[stationId] ?? const <StationMilestoneBonus>[];
  }

  double profitMultiplier(String stationId, int level) {
    var multiplier = 1.0;
    for (final bonus in bonusesForStation(stationId)) {
      if (level >= bonus.level) {
        multiplier *= bonus.profitMultiplier;
      }
    }
    return multiplier;
  }

  double productionSpeedMultiplier(String stationId, int level) {
    var multiplier = 1.0;
    for (final bonus in bonusesForStation(stationId)) {
      if (level >= bonus.level) {
        multiplier *= bonus.productionSpeedMultiplier;
      }
    }
    return multiplier;
  }

  StationMilestoneBonus? nextMilestone(String stationId, int level) {
    for (final bonus in bonusesForStation(stationId)) {
      if (bonus.level > level) {
        return bonus;
      }
    }
    return null;
  }
}
