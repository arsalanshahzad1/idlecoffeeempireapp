class CustomerTypeConfig {
  const CustomerTypeConfig({
    required this.id,
    required this.name,
    required this.spawnWeight,
    required this.rewardMultiplier,
    required this.patienceMultiplier,
    required this.colorHex,
    this.requiresStationId,
    this.assetPath,
    this.onServeSpawnBoostMultiplier = 1.0,
    this.onServeSpawnBoostDurationSeconds = 0,
  });

  final String id;
  final String name;
  final double spawnWeight;
  final double rewardMultiplier;
  final double patienceMultiplier;
  final int colorHex;
  final String? requiresStationId;
  final String? assetPath;
  final double onServeSpawnBoostMultiplier;
  final double onServeSpawnBoostDurationSeconds;
}
