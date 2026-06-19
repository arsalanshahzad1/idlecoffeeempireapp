import '../models/manager_config.dart';

const List<ManagerConfig> managerConfigs = <ManagerConfig>[
  ManagerConfig(
    id: 'head_barista',
    name: 'Head Barista',
    description: 'Espresso automation speed +20%',
    cost: 50000,
    unlock: ManagerUnlockRequirement(
      stationLevel: StationLevelRequirement(stationId: 'espresso_machine', level: 25),
    ),
    effect: ManagerEffect(stationSpeedBoostByStation: <String, double>{'espresso_machine': 0.20}),
  ),
  ManagerConfig(
    id: 'operations_manager',
    name: 'Operations Manager',
    description: 'Customer service speed +20%',
    cost: 100000,
    unlock: ManagerUnlockRequirement(
      stationLevel: StationLevelRequirement(stationId: 'cashier_counter', level: 25),
    ),
    effect: ManagerEffect(stationSpeedBoostByStation: <String, double>{'cashier_counter': 0.20}),
  ),
  ManagerConfig(
    id: 'marketing_manager',
    name: 'Marketing Manager',
    description: 'Customer spawn rate +15%',
    cost: 150000,
    unlock: ManagerUnlockRequirement(expansionStageId: 'busy_shop'),
    effect: ManagerEffect(customerSpawnRateBoost: 0.15),
  ),
  ManagerConfig(
    id: 'store_director',
    name: 'Store Director',
    description: 'Global income +10%',
    cost: 300000,
    unlock: ManagerUnlockRequirement(playerLevel: 15),
    effect: ManagerEffect(globalIncomeBoost: 0.10),
  ),
];
