enum RewardedPlacement {
  doubleOfflineIncome,
  instantCoinsBonus,
  speedBoost,
  freeGems,
  skipStationTimer,
}

abstract class AdService {
  const AdService();

  Future<bool> showRewarded({
    required RewardedPlacement placement,
  });
}
