import '../models/task_state.dart';

class TaskManager {
  const TaskManager();

  Map<String, TaskState> ensureDefaults(List<TaskConfig> configs, Map<String, TaskState> existing) {
    final next = <String, TaskState>{};
    for (final config in configs) {
      next[config.id] = existing[config.id] ?? TaskState(taskId: config.id, progress: 0, claimed: false);
    }
    return next;
  }

  Map<String, TaskState> applyMetric({
    required List<TaskConfig> configs,
    required Map<String, TaskState> states,
    required String metric,
    required int delta,
  }) {
    if (delta <= 0) {
      return states;
    }
    final next = Map<String, TaskState>.from(states);
    for (final config in configs) {
      if (config.metric != metric) {
        continue;
      }
      final prev = next[config.id] ?? TaskState(taskId: config.id, progress: 0, claimed: false);
      if (prev.claimed) {
        continue;
      }
      final progress = (prev.progress + delta).clamp(0, config.target);
      next[config.id] = prev.copyWith(progress: progress);
    }
    return next;
  }

  bool isComplete(TaskConfig config, TaskState state) {
    return state.progress >= config.target;
  }
}
