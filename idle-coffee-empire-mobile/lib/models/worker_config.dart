class WorkerConfig {
  const WorkerConfig({
    required this.id,
    required this.name,
    required this.assignedStationId,
    required this.hireCost,
    required this.baseEfficiencyMultiplier,
    required this.efficiencyPerLevel,
    required this.baseUpgradeCost,
    required this.upgradeCostGrowth,
    this.assetPath,
  });

  final String id;
  final String name;
  final String assignedStationId;
  final double hireCost;
  final double baseEfficiencyMultiplier;
  final double efficiencyPerLevel;
  final double baseUpgradeCost;
  final double upgradeCostGrowth;
  final String? assetPath;
}
