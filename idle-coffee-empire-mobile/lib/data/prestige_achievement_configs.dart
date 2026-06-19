import '../models/prestige_achievement_config.dart';

const List<PrestigeAchievementConfig> prestigeAchievementConfigs =
    <PrestigeAchievementConfig>[
      PrestigeAchievementConfig(
        id: 'first_prestige',
        title: 'First Prestige',
        description: 'Prestige for the first time.',
        metric: PrestigeAchievementMetric.prestigeCount,
        targetValue: 1,
        rewardXp: 80,
      ),
      PrestigeAchievementConfig(
        id: 'earn_10_prestige_points',
        title: 'Prestige Builder',
        description: 'Earn 10 lifetime prestige points.',
        metric: PrestigeAchievementMetric.lifetimePrestigePoints,
        targetValue: 10,
        rewardXp: 120,
        rewardCoins: 500,
      ),
      PrestigeAchievementConfig(
        id: 'buy_first_permanent_upgrade',
        title: 'Forever Upgrade',
        description: 'Buy your first permanent upgrade.',
        metric: PrestigeAchievementMetric.permanentUpgradesPurchased,
        targetValue: 1,
        rewardPrestigePoints: 1,
      ),
      PrestigeAchievementConfig(
        id: 'prestige_3_times',
        title: 'Loop Master',
        description: 'Prestige 3 times.',
        metric: PrestigeAchievementMetric.prestigeCount,
        targetValue: 3,
        rewardXp: 180,
        rewardPrestigePoints: 2,
      ),
      PrestigeAchievementConfig(
        id: 'cozy_after_prestige',
        title: 'Back to Cozy',
        description: 'Reach Cozy Cafe after your first prestige.',
        metric: PrestigeAchievementMetric.expansionAfterPrestigeCount,
        targetValue: 1,
        rewardXp: 100,
        rewardCoins: 750,
      ),
    ];
