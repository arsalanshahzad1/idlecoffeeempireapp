import '../models/task_state.dart';

const List<TaskConfig> dailyTaskConfigs = <TaskConfig>[
  TaskConfig(id: 'daily_serve_25', type: TaskType.daily, title: 'Serve 25 customers', target: 25, metric: 'customers_served', rewardCoins: 2500, rewardGems: 2, rewardEventBeans: 5),
  TaskConfig(id: 'daily_earn_10k', type: TaskType.daily, title: 'Earn 10K coins', target: 10000, metric: 'coins_earned', rewardCoins: 3000, rewardGems: 1, rewardEventBeans: 5),
  TaskConfig(id: 'daily_upgrade_station_3', type: TaskType.daily, title: 'Upgrade any station 3 times', target: 3, metric: 'station_upgrades', rewardCoins: 3500, rewardGems: 2, rewardEventBeans: 8),
  TaskConfig(id: 'daily_claim_milestone_1', type: TaskType.daily, title: 'Claim 1 milestone', target: 1, metric: 'milestones_claimed', rewardCoins: 4000, rewardGems: 2, rewardEventBeans: 8),
  TaskConfig(id: 'daily_activate_boost_1', type: TaskType.daily, title: 'Activate 1 boost', target: 1, metric: 'boosts_activated', rewardCoins: 3000, rewardGems: 2, rewardEventBeans: 8),
];

const List<TaskConfig> weeklyTaskConfigs = <TaskConfig>[
  TaskConfig(id: 'weekly_serve_500', type: TaskType.weekly, title: 'Serve 500 customers', target: 500, metric: 'customers_served', rewardCoins: 25000, rewardGems: 8, rewardEventBeans: 35),
  TaskConfig(id: 'weekly_earn_1m', type: TaskType.weekly, title: 'Earn 1M coins', target: 1000000, metric: 'coins_earned', rewardCoins: 50000, rewardGems: 12, rewardEventBeans: 40),
  TaskConfig(id: 'weekly_prestige_1', type: TaskType.weekly, title: 'Prestige once', target: 1, metric: 'prestige_count', rewardCoins: 45000, rewardGems: 10, rewardEventBeans: 40),
  TaskConfig(id: 'weekly_buy_decor_3', type: TaskType.weekly, title: 'Buy 3 decorations', target: 3, metric: 'decorations_bought', rewardCoins: 40000, rewardGems: 8, rewardEventBeans: 35),
  TaskConfig(id: 'weekly_complete_daily_10', type: TaskType.weekly, title: 'Complete 10 daily tasks', target: 10, metric: 'daily_tasks_completed', rewardCoins: 55000, rewardGems: 14, rewardEventBeans: 50),
];
