import 'economy_balance_config.dart';

class GameBalanceConfig {
  const GameBalanceConfig._();

  static const double offlineMultiplier = EconomyBalanceConfig.offlineMultiplier;
  static const int maxOfflineSeconds = EconomyBalanceConfig.maxOfflineSeconds;
  static const Duration autosaveInterval = EconomyBalanceConfig.autosaveInterval;
}
