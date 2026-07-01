import '../models/shop_tier_config.dart';

/// 6-tier shop progression: Roadside Stall → Full Coffee Shop.
/// upgradeCost = cost to upgrade TO that tier (looked up via currentTier + 1).
/// Costs scale at ~5-6× per tier, consistent with station upgrade cost curves.
const List<ShopTierConfig> shopTierConfigs = <ShopTierConfig>[
  ShopTierConfig(
    tier: 1,
    name: 'Roadside Stall',
    description: 'A humble stand by the road. Just you and a hot plate.',
    upgradeCost: 0,
    globalEarningsMultiplier: 1.0,
    maxActiveStations: 1,
    assetPath: 'assets/images/shop/tier1_roadside_stall.png',
  ),
  ShopTierConfig(
    tier: 2,
    name: 'Pushcart',
    description: 'A mobile cart — room for more items and a bigger crowd.',
    upgradeCost: 500,
    globalEarningsMultiplier: 1.2,
    maxActiveStations: 2,
    assetPath: 'assets/images/shop/tier2_pushcart.png',
  ),
  ShopTierConfig(
    tier: 3,
    name: 'Kiosk',
    description: 'A proper kiosk with a menu board and equipment space.',
    upgradeCost: 3000,
    globalEarningsMultiplier: 1.5,
    maxActiveStations: 3,
    assetPath: 'assets/images/shop/tier3_kiosk.png',
  ),
  ShopTierConfig(
    tier: 4,
    name: 'Food Truck',
    description: 'Your business on wheels. Park anywhere, serve everyone.',
    upgradeCost: 15000,
    globalEarningsMultiplier: 1.9,
    maxActiveStations: 4,
    assetPath: 'assets/images/shop/tier4_food_truck.png',
  ),
  ShopTierConfig(
    tier: 5,
    name: 'Small Café',
    description: 'A real café — seats, ambience, and a growing reputation.',
    upgradeCost: 80000,
    globalEarningsMultiplier: 2.4,
    maxActiveStations: 5,
    assetPath: 'assets/images/shop/tier5_small_cafe.png',
  ),
  ShopTierConfig(
    tier: 6,
    name: 'Full Coffee Shop',
    description: 'The full empire. Premium brews, loyal regulars, city buzz.',
    upgradeCost: 400000,
    globalEarningsMultiplier: 3.0,
    maxActiveStations: 6,
    assetPath: 'assets/images/shop/tier6_coffee_shop.png',
  ),
];
