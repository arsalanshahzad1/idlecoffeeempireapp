class ShopTierConfig {
  const ShopTierConfig({
    required this.tier,
    required this.name,
    required this.description,
    required this.upgradeCost,
    required this.globalEarningsMultiplier,
    required this.maxActiveStations,
    required this.assetPath,
  });

  final int tier;
  final String name;
  final String description;

  /// Cost to upgrade TO this tier (tier 1 = 0, never purchased directly).
  final double upgradeCost;

  /// Multiplicative factor applied on top of all other income multipliers.
  final double globalEarningsMultiplier;

  /// Maximum number of stations that may be unlocked at this tier.
  final int maxActiveStations;

  final String assetPath;
}
