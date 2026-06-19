import '../models/worker_config.dart';

const List<WorkerConfig> workerConfigs = <WorkerConfig>[
  WorkerConfig(
    id: 'barista_worker',
    name: 'Coffee Cook',
    assetPath: 'assets/images/workers/barista_worker.png',
    assignedStationId: 'espresso_machine',
    hireCost: 80,
    baseEfficiencyMultiplier: 1.0,
    efficiencyPerLevel: 0.12,
    baseUpgradeCost: 90,
    upgradeCostGrowth: 1.33,
  ),
  WorkerConfig(
    id: 'burger_cook',
    name: 'Burger Cook',
    assetPath: 'assets/images/workers/cashier_worker.png',
    assignedStationId: 'coffee_grinder',
    hireCost: 220,
    baseEfficiencyMultiplier: 1.0,
    efficiencyPerLevel: 0.10,
    baseUpgradeCost: 140,
    upgradeCostGrowth: 1.35,
  ),
  WorkerConfig(
    id: 'pastry_chef',
    name: 'Cake Cook',
    assetPath: 'assets/images/workers/pastry_chef.png',
    assignedStationId: 'pastry_display',
    hireCost: 900,
    baseEfficiencyMultiplier: 1.0,
    efficiencyPerLevel: 0.12,
    baseUpgradeCost: 2400,
    upgradeCostGrowth: 1.36,
  ),
];
