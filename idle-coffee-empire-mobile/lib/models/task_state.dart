enum TaskType { daily, weekly }

class TaskConfig {
  const TaskConfig({
    required this.id,
    required this.type,
    required this.title,
    required this.target,
    required this.metric,
    required this.rewardCoins,
    required this.rewardGems,
    this.rewardEventBeans = 0,
  });

  final String id;
  final TaskType type;
  final String title;
  final int target;
  final String metric;
  final double rewardCoins;
  final int rewardGems;
  final int rewardEventBeans;
}

class TaskState {
  const TaskState({
    required this.taskId,
    required this.progress,
    required this.claimed,
  });

  final String taskId;
  final int progress;
  final bool claimed;

  TaskState copyWith({int? progress, bool? claimed}) {
    return TaskState(
      taskId: taskId,
      progress: progress ?? this.progress,
      claimed: claimed ?? this.claimed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'taskId': taskId,
      'progress': progress,
      'claimed': claimed,
    };
  }

  factory TaskState.fromMap(Map<dynamic, dynamic> map) {
    return TaskState(
      taskId: map['taskId'] as String? ?? '',
      progress: (map['progress'] as num?)?.toInt() ?? 0,
      claimed: map['claimed'] as bool? ?? false,
    );
  }
}
