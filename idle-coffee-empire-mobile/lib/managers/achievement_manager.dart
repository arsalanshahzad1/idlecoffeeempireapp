import '../data/achievement_configs.dart';
import '../features/game/game_state.dart';
import '../models/achievement_config.dart';
import '../models/achievement_state.dart';

class AchievementManager {
  const AchievementManager();

  List<AchievementConfig> get configs => achievementConfigs;

  List<AchievementState> buildAchievements(GameState state) {
    return configs
        .map((config) {
          final progress = progressForConfig(state, config);
          return AchievementState(
            config: config,
            progressValue: progress,
            completed: progress >= config.targetValue,
            claimed: state.claimedAchievementIds.contains(config.id),
          );
        })
        .toList(growable: false);
  }

  int progressForConfig(GameState state, AchievementConfig config) {
    switch (config.metric) {
      case AchievementMetric.lifetimeCoinsEarned:
        return state.lifetimeCoinsEarned.floor();
      case AchievementMetric.lifetimeCustomersServed:
        return state.lifetimeCustomersServed;
      case AchievementMetric.decorationsPurchased:
        return state.purchasedDecorationIds.length;
      case AchievementMetric.workersHired:
        return state.workersHired.length;
      case AchievementMetric.stationsUnlocked:
        return state.stations.values.where((s) => s.isUnlocked).length;
      case AchievementMetric.playerLevel:
        return state.playerLevel;
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
