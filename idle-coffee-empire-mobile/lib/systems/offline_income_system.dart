import '../data/economy_balance_config.dart';

class OfflineIncomeSystem {
  const OfflineIncomeSystem();

  double calculate({
    required double totalCoinsPerSecond,
    required DateTime fromUtc,
    required DateTime toUtc,
    required double offlineMultiplier,
  }) {
    final rawSeconds = toUtc.difference(fromUtc).inSeconds;
    final cappedSeconds = rawSeconds.clamp(0, EconomyBalanceConfig.maxOfflineSeconds);
    return totalCoinsPerSecond * cappedSeconds * offlineMultiplier;
  }
}
