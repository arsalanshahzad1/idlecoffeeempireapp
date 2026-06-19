class EconomyBalanceConfig {
  const EconomyBalanceConfig._();

  static const double offlineMultiplier = 0.6;
  static const int maxOfflineSeconds = 2 * 60 * 60;
  static const Duration autosaveInterval = Duration(seconds: 15);

  static const double customerSpawnIntervalSeconds = 2.8;
  static const int maxActiveCustomers = 8;
  static const int maxQueueCustomers = 5;
  static const double customerMoveSpeed = 130;
  static const double customerLeaveSpeed = 155;

  static const double espressoBaseCupsPerCycle = 1;
  static const double grinderEfficiencyPerLevel = 0.12;
  static const double cashierBaseServePerCycle = 1;

  static const double workerAutomationRateMultiplier = 1;
  static const double stationUpgradeCostExponent = 1.38;
}
