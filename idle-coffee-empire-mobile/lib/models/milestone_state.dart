import 'milestone_config.dart';

class MilestoneState {
  const MilestoneState({
    required this.config,
    required this.progressValue,
    required this.claimed,
  });

  final MilestoneConfig config;
  final int progressValue;
  final bool claimed;

  bool get completed => progressValue >= config.targetValue;
  bool get claimable => completed && !claimed;
  double get progressRatio =>
      (progressValue / config.targetValue).clamp(0.0, 1.0).toDouble();
}
