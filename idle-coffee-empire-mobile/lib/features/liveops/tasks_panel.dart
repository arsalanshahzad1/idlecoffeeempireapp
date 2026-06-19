import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/task_configs.dart';
import '../../models/task_state.dart';
import '../game/game_controller.dart';

class TasksPanel extends ConsumerWidget {
  const TasksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    Widget buildList(List<TaskConfig> configs, bool daily) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: configs.map((config) {
          final taskState = daily ? state.dailyTasks[config.id] : state.weeklyTasks[config.id];
          final progress = taskState?.progress ?? 0;
          final claimed = taskState?.claimed ?? false;
          final done = progress >= config.target;
          return ListTile(
            title: Text(config.title),
            subtitle: Text('$progress / ${config.target}'),
            trailing: claimed
                ? const Chip(label: Text('Claimed'))
                : FilledButton.tonal(
                    onPressed: done ? () => controller.claimTaskReward(config.id) : null,
                    child: const Text('Claim'),
                  ),
          );
        }).toList(growable: false),
      );
    }

    return AlertDialog(
      title: const Text('Tasks'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 500),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Login streak: ${state.loginStreak.currentStreakDays} days (best ${state.loginStreak.bestStreakDays})'),
              const SizedBox(height: 8),
              const Text('Daily', style: TextStyle(fontWeight: FontWeight.w700)),
              buildList(dailyTaskConfigs, true),
              const SizedBox(height: 8),
              const Text('Weekly', style: TextStyle(fontWeight: FontWeight.w700)),
              buildList(weeklyTaskConfigs, false),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
