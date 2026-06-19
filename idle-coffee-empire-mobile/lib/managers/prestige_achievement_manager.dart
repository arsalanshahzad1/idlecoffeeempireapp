import '../data/prestige_achievement_configs.dart';
import '../features/game/game_state.dart';
import '../models/prestige_achievement_config.dart';
import '../models/prestige_achievement_state.dart';

class PrestigeAchievementManager {
  const PrestigeAchievementManager();

  List<PrestigeAchievementConfig> get configs => prestigeAchievementConfigs;

  List<PrestigeAchievementState> buildAchievements(GameState state) {
    return configs
        .map((config) {
          final progress = progressForConfig(state, config);
          return PrestigeAchievementState(
            config: config,
            progressValue: progress,
            completed: progress >= config.targetValue,
            claimed: state.claimedPrestigeAchievementIds.contains(config.id),
          );
        })
        .toList(growable: false);
  }

  int progressForConfig(GameState state, PrestigeAchievementConfig config) {
    switch (config.metric) {
      case PrestigeAchievementMetric.prestigeCount:
        return state.prestigeCount;
      case PrestigeAchievementMetric.lifetimePrestigePoints:
        return state.lifetimePrestigePoints;
      case PrestigeAchievementMetric.permanentUpgradesPurchased:
        return state.purchasedPermanentUpgradeIds.length;
      case PrestigeAchievementMetric.expansionAfterPrestigeCount:
        return state.timesReachedCozyCafeAfterPrestige;
    }
  }

  Set<String> completedIdsForState(GameState state) {
    final completed = <String>{};
    for (final config in configs) {
      if (progressForConfig(state, config) >= config.targetValue) {
        completed.add(config.id);
      }
    }
    return completed;
  }
}
