class ProgressionBalanceConfig {
  const ProgressionBalanceConfig._();

  static const int baseXpToNextLevel = 100;
  static const double xpGrowthFactor = 1.28;

  static const int xpPerCustomerServed = 8;
  static const int xpPerStationUpgrade = 25;
  static const int xpPerStationUnlock = 40;
  static const int xpPerWorkerHire = 30;
  static const int xpPerWorkerUpgrade = 15;

  static int xpToNextLevel(int currentLevel) {
    final level = currentLevel < 1 ? 1 : currentLevel;
    return (baseXpToNextLevel * _pow(xpGrowthFactor, level - 1)).round();
  }

  static double _pow(double base, int exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
