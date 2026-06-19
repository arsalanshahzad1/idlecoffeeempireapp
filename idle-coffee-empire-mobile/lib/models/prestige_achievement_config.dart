enum PrestigeAchievementMetric {
  prestigeCount,
  lifetimePrestigePoints,
  permanentUpgradesPurchased,
  expansionAfterPrestigeCount,
}

class PrestigeAchievementConfig {
  const PrestigeAchievementConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.targetValue,
    this.rewardCoins = 0,
    this.rewardXp = 0,
    this.rewardPrestigePoints = 0,
  });

  final String id;
  final String title;
  final String description;
  final PrestigeAchievementMetric metric;
  final int targetValue;
  final double rewardCoins;
  final int rewardXp;
  final int rewardPrestigePoints;
}
