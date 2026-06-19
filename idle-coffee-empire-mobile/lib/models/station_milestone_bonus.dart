class StationMilestoneBonus {
  const StationMilestoneBonus({
    required this.level,
    this.profitMultiplier = 1.0,
    this.productionSpeedMultiplier = 1.0,
  });

  final int level;
  final double profitMultiplier;
  final double productionSpeedMultiplier;
}
