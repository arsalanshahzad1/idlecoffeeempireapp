class ExpansionConfig {
  const ExpansionConfig({
    required this.id,
    required this.name,
    required this.minLifetimeCoinsEarned,
    required this.minCustomersServed,
    required this.minStationLevels,
    required this.incomeMultiplier,
    required this.customerSpawnRateMultiplier,
    required this.queueCapacityBonus,
    required this.floorColorHex,
    this.floorScale = 1.0,
  });

  final String id;
  final String name;
  final double minLifetimeCoinsEarned;
  final int minCustomersServed;
  final Map<String, int> minStationLevels;
  final double incomeMultiplier;
  final double customerSpawnRateMultiplier;
  final int queueCapacityBonus;
  final int floorColorHex;
  final double floorScale;
}
