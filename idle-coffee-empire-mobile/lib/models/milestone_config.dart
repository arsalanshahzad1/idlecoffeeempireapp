enum MilestoneConditionType {
  customersServed,
  lifetimeCoinsEarned,
  stationLevelReached,
  workerHiredCount,
  unlockedStationsCount,
  playerLevelReached,
  decorationsPurchasedCount,
  anyStationLevelReached,
  expansionStageReached,
  prestigePointsEarned,
  permanentUpgradesPurchased,
}

class MilestoneConfig {
  const MilestoneConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.conditionType,
    required this.targetValue,
    this.stationId,
    this.rewardCoins = 0,
    this.rewardXp = 0,
  });

  final String id;
  final String title;
  final String description;
  final MilestoneConditionType conditionType;
  final int targetValue;
  final String? stationId;
  final double rewardCoins;
  final int rewardXp;
}
