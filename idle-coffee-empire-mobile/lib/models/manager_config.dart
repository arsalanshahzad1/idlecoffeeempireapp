class ManagerConfig {
  const ManagerConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.unlock,
    required this.effect,
  });

  final String id;
  final String name;
  final String description;
  final double cost;
  final ManagerUnlockRequirement unlock;
  final ManagerEffect effect;
}

class ManagerUnlockRequirement {
  const ManagerUnlockRequirement({
    this.stationLevel,
    this.expansionStageId,
    this.playerLevel,
  });

  final StationLevelRequirement? stationLevel;
  final String? expansionStageId;
  final int? playerLevel;
}

class StationLevelRequirement {
  const StationLevelRequirement({required this.stationId, required this.level});

  final String stationId;
  final int level;
}

class ManagerEffect {
  const ManagerEffect({
    this.stationSpeedBoostByStation = const <String, double>{},
    this.customerSpawnRateBoost = 0,
    this.globalIncomeBoost = 0,
  });

  final Map<String, double> stationSpeedBoostByStation;
  final double customerSpawnRateBoost;
  final double globalIncomeBoost;
}
