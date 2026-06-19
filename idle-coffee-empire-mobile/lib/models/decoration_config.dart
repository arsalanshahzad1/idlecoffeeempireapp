class DecorationConfig {
  const DecorationConfig({
    required this.id,
    required this.name,
    required this.cost,
    required this.incomeMultiplier,
    required this.spawnRateMultiplier,
    required this.queueCapacityBonus,
    required this.gridX,
    required this.gridY,
    required this.colorHex,
    this.assetPath,
  });

  final String id;
  final String name;
  final double cost;
  final double incomeMultiplier;
  final double spawnRateMultiplier;
  final int queueCapacityBonus;
  final double gridX;
  final double gridY;
  final int colorHex;
  final String? assetPath;
}
