import '../data/milestone_configs.dart';
import '../features/game/game_state.dart';
import '../models/milestone_config.dart';
import '../models/milestone_state.dart';

class MilestoneManager {
  const MilestoneManager();
  static const Map<String, int> _expansionOrder = <String, int>{
    'small_cart': 0,
    'cozy_cafe': 1,
    'busy_shop': 2,
    'downtown_cafe': 3,
    'premium_house': 4,
    'empire_hq': 5,
  };

  List<MilestoneConfig> get configs => milestoneConfigs;

  List<MilestoneState> buildMilestones(GameState state) {
    return milestoneConfigs
        .map(
          (config) => MilestoneState(
            config: config,
            progressValue: progressForConfig(state, config),
            claimed: state.claimedMilestoneIds.contains(config.id),
          ),
        )
        .toList(growable: false);
  }

  int progressForConfig(GameState state, MilestoneConfig config) {
    switch (config.conditionType) {
      case MilestoneConditionType.customersServed:
        return state.lifetimeCustomersServed;
      case MilestoneConditionType.lifetimeCoinsEarned:
        return state.lifetimeCoinsEarned.floor();
      case MilestoneConditionType.stationLevelReached:
        final station = state.stations[config.stationId];
        return station?.level ?? 0;
      case MilestoneConditionType.workerHiredCount:
        return state.workersHired.length;
      case MilestoneConditionType.unlockedStationsCount:
        return state.stations.values.where((s) => s.isUnlocked).length;
      case MilestoneConditionType.playerLevelReached:
        return state.playerLevel;
      case MilestoneConditionType.decorationsPurchasedCount:
        return state.purchasedDecorationIds.length;
      case MilestoneConditionType.anyStationLevelReached:
        var maxLevel = 0;
        for (final station in state.stations.values) {
          if (station.level > maxLevel) {
            maxLevel = station.level;
          }
        }
        return maxLevel;
      case MilestoneConditionType.expansionStageReached:
        return _expansionOrder[state.expansionStageId] ?? 0;
      case MilestoneConditionType.prestigePointsEarned:
        return state.lifetimePrestigePoints;
      case MilestoneConditionType.permanentUpgradesPurchased:
        return state.purchasedPermanentUpgradeIds.length;
    }
  }
}
