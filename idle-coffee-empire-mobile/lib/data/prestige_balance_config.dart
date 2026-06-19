import 'dart:math' as math;

class PrestigeBalanceConfig {
  const PrestigeBalanceConfig._();

  static const double potentialCoinsDivisor = 90000;
  static const double pointsToMultiplierFactor = 0.05;
  static const bool resetPlayerLevelOnPrestige = true;

  static int potentialPointsFromLifetimeCoins(double lifetimeCoinsEarned) {
    if (lifetimeCoinsEarned <= 0) {
      return 0;
    }
    return math.sqrt(lifetimeCoinsEarned / potentialCoinsDivisor).floor();
  }

  static double multiplierFromPoints(int prestigePoints) {
    if (prestigePoints <= 0) {
      return 1.0;
    }
    return 1.0 + (prestigePoints * pointsToMultiplierFactor);
  }
}
