enum PermanentUpgradeEffectType {
  stationProductionSpeedBoost,
  customerRewardBoost,
  workerEfficiencyBoost,
  customerSpawnRateBoost,
}

class PermanentUpgradeConfig {
  const PermanentUpgradeConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.costPrestigePoints,
    required this.effectType,
    required this.effectValue,
  });

  final String id;
  final String title;
  final String description;
  final int costPrestigePoints;
  final PermanentUpgradeEffectType effectType;
  final double effectValue;
}
