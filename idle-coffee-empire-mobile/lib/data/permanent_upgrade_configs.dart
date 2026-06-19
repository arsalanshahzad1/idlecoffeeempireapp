import '../models/permanent_upgrade_config.dart';

const List<PermanentUpgradeConfig> permanentUpgradeConfigs =
    <PermanentUpgradeConfig>[
      PermanentUpgradeConfig(
        id: 'faster_brewing',
        title: 'Faster Brewing',
        description: 'Station production speed +5%',
        costPrestigePoints: 5,
        effectType: PermanentUpgradeEffectType.stationProductionSpeedBoost,
        effectValue: 0.05,
      ),
      PermanentUpgradeConfig(
        id: 'better_branding',
        title: 'Better Branding',
        description: 'Customer reward +8%',
        costPrestigePoints: 8,
        effectType: PermanentUpgradeEffectType.customerRewardBoost,
        effectValue: 0.08,
      ),
      PermanentUpgradeConfig(
        id: 'efficient_staff',
        title: 'Efficient Staff',
        description: 'Worker efficiency +10%',
        costPrestigePoints: 10,
        effectType: PermanentUpgradeEffectType.workerEfficiencyBoost,
        effectValue: 0.10,
      ),
      PermanentUpgradeConfig(
        id: 'bigger_reputation',
        title: 'Bigger Reputation',
        description: 'Customer spawn rate +10%',
        costPrestigePoints: 15,
        effectType: PermanentUpgradeEffectType.customerSpawnRateBoost,
        effectValue: 0.10,
      ),
    ];
