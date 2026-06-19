enum AchievementMetric {
  lifetimeCoinsEarned,
  lifetimeCustomersServed,
  decorationsPurchased,
  workersHired,
  stationsUnlocked,
  playerLevel,
}

class AchievementConfig {
  const AchievementConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.targetValue,
    required this.rewardCoins,
    required this.rewardXp,
  });

  final String id;
  final String title;
  final String description;
  final AchievementMetric metric;
  final int targetValue;
  final double rewardCoins;
  final int rewardXp;
}
