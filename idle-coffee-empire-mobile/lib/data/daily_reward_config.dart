class DailyRewardConfig {
  const DailyRewardConfig({
    required this.day,
    required this.coins,
    required this.gems,
    this.boostId,
    this.boostDurationSeconds = 0,
    this.prestigePoints = 0,
  });

  final int day;
  final double coins;
  final int gems;
  final String? boostId;
  final int boostDurationSeconds;
  final int prestigePoints;
}

class DailyRewardCycleConfig {
  const DailyRewardCycleConfig({
    required this.rewards,
    required this.resetOnMissedDay,
  });

  final List<DailyRewardConfig> rewards;
  final bool resetOnMissedDay;
}

const DailyRewardCycleConfig dailyRewardCycleConfig = DailyRewardCycleConfig(
  resetOnMissedDay: true,
  rewards: <DailyRewardConfig>[
    DailyRewardConfig(day: 1, coins: 500, gems: 1),
    DailyRewardConfig(day: 2, coins: 1000, gems: 2),
    DailyRewardConfig(day: 3, coins: 1800, gems: 2, boostId: 'speed_boost', boostDurationSeconds: 300),
    DailyRewardConfig(day: 4, coins: 2600, gems: 3),
    DailyRewardConfig(day: 5, coins: 3500, gems: 4, boostId: 'income_boost', boostDurationSeconds: 300),
    DailyRewardConfig(day: 6, coins: 5000, gems: 5),
    DailyRewardConfig(day: 7, coins: 8000, gems: 8, prestigePoints: 1),
  ],
);
