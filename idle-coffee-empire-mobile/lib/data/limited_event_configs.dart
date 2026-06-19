class LimitedEventConfig {
  const LimitedEventConfig({
    required this.id,
    required this.title,
    required this.description,
    this.espressoProfitMultiplier = 1.0,
    this.customerSpawnRateMultiplier = 1.0,
    this.customerRewardMultiplier = 1.0,
    this.vipChanceMultiplier = 1.0,
    this.vipRewardMultiplier = 1.0,
    this.decorationCostMultiplier = 1.0,
  });

  final String id;
  final String title;
  final String description;
  final double espressoProfitMultiplier;
  final double customerSpawnRateMultiplier;
  final double customerRewardMultiplier;
  final double vipChanceMultiplier;
  final double vipRewardMultiplier;
  final double decorationCostMultiplier;
}

const List<LimitedEventConfig> limitedEventConfigs = <LimitedEventConfig>[
  LimitedEventConfig(
    id: 'double_espresso_weekend',
    title: 'Double Espresso Weekend',
    description: 'Espresso profit is doubled.',
    espressoProfitMultiplier: 2.0,
  ),
  LimitedEventConfig(
    id: 'rush_hour_event',
    title: 'Rush Hour Event',
    description: 'Customer spawns and rewards are boosted.',
    customerSpawnRateMultiplier: 1.5,
    customerRewardMultiplier: 1.5,
  ),
  LimitedEventConfig(
    id: 'vip_coffee_week',
    title: 'VIP Coffee Week',
    description: 'VIP visitors appear more often and pay more.',
    vipChanceMultiplier: 1.6,
    vipRewardMultiplier: 1.6,
  ),
  LimitedEventConfig(
    id: 'decoration_festival',
    title: 'Decoration Festival',
    description: 'Decoration prices are reduced.',
    decorationCostMultiplier: 0.7,
  ),
];
