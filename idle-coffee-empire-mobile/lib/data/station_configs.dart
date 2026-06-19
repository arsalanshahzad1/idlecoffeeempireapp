import '../models/station_config.dart';

const List<StationConfig> stationConfigs = <StationConfig>[
  StationConfig(
    id: 'espresso_machine',
    name: 'Coffee',
    assetPath: 'assets/images/stations/espresso_machine.png',
    baseProfit: 5,
    productionTimeSeconds: 2.6,
    baseUpgradeCost: 20,
    unlockCost: 0,
    gridX: 0,
    gridY: 0,
  ),
  StationConfig(
    id: 'coffee_grinder',
    name: 'Burger',
    assetPath: 'assets/images/stations/coffee_grinder.png',
    baseProfit: 18,
    productionTimeSeconds: 4.5,
    baseUpgradeCost: 90,
    unlockCost: 100,
    gridX: 0,
    gridY: 1,
  ),
  StationConfig(
    id: 'pastry_display',
    name: 'Cake',
    assetPath: 'assets/images/stations/pastry_display.png',
    baseProfit: 55,
    productionTimeSeconds: 7,
    baseUpgradeCost: 260,
    unlockCost: 600,
    gridX: 0,
    gridY: 2,
  ),
];
