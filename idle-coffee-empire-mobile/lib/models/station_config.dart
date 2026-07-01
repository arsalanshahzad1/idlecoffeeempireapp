class StationConfig {
  const StationConfig({
    required this.id,
    required this.name,
    required this.baseProfit,
    required this.productionTimeSeconds,
    required this.baseUpgradeCost,
    required this.unlockCost,
    required this.gridX,
    required this.gridY,
    required this.secondChefUnlockLevel,
    this.assetPath,
  });

  final String id;
  final String name;
  final double baseProfit;
  final double productionTimeSeconds;
  final double baseUpgradeCost;
  final double unlockCost;
  final double gridX;
  final double gridY;
  /// Station level at which the second parallel chef slot activates.
  final int secondChefUnlockLevel;
  final String? assetPath;
}
