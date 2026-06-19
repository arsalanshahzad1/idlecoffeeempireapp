class BoostConfig {
  const BoostConfig({
    required this.id,
    required this.title,
    required this.durationSeconds,
    this.incomeMultiplier = 1.0,
    this.productionSpeedMultiplier = 1.0,
    this.spawnRateMultiplier = 1.0,
    this.gemCost = 0,
  });

  final String id;
  final String title;
  final int durationSeconds;
  final double incomeMultiplier;
  final double productionSpeedMultiplier;
  final double spawnRateMultiplier;
  final int gemCost;
}

class MonetizationConfig {
  const MonetizationConfig._();

  static const int offlineDoubleMultiplier = 2;
  static const int rewardedGemAmount = 2;
  static const double rewardedInstantCoinSecondsWorth = 120;
  static const int rewardedSkipStationSeconds = 18;

  static const int coinPackSmallGemCost = 12;
  static const double coinPackSmallSecondsWorth = 300;
  static const int stationSkipGemCost = 4;

  static const BoostConfig incomeBoost = BoostConfig(
    id: 'income_x2',
    title: 'Income x2',
    durationSeconds: 5 * 60,
    incomeMultiplier: 2.0,
    gemCost: 16,
  );
  static const BoostConfig productionBoost = BoostConfig(
    id: 'production_x2',
    title: 'Production x2',
    durationSeconds: 5 * 60,
    productionSpeedMultiplier: 2.0,
    gemCost: 14,
  );
  static const BoostConfig customerRushBoost = BoostConfig(
    id: 'customer_rush_x2',
    title: 'Customer Rush x2',
    durationSeconds: 5 * 60,
    spawnRateMultiplier: 2.0,
    gemCost: 10,
  );

  static const List<BoostConfig> boosts = <BoostConfig>[
    incomeBoost,
    productionBoost,
    customerRushBoost,
  ];
}
