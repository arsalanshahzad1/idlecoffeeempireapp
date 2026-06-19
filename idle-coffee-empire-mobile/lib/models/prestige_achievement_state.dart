import 'prestige_achievement_config.dart';

class PrestigeAchievementState {
  const PrestigeAchievementState({
    required this.config,
    required this.progressValue,
    required this.completed,
    required this.claimed,
  });

  final PrestigeAchievementConfig config;
  final int progressValue;
  final bool completed;
  final bool claimed;

  double get progressRatio {
    if (config.targetValue <= 0) {
      return 1.0;
    }
    return (progressValue / config.targetValue).clamp(0.0, 1.0);
  }
}
