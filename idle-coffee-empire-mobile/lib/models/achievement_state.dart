import 'achievement_config.dart';

class AchievementState {
  const AchievementState({
    required this.config,
    required this.progressValue,
    required this.completed,
    required this.claimed,
  });

  final AchievementConfig config;
  final int progressValue;
  final bool completed;
  final bool claimed;

  double get progressRatio {
    if (config.targetValue <= 0) {
      return 1;
    }
    return (progressValue / config.targetValue).clamp(0.0, 1.0);
  }
}
