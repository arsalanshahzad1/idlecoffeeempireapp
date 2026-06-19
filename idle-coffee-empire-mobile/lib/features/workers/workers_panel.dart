import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/number_formatter.dart';
import '../game/game_controller.dart';

class WorkersPanel extends ConsumerWidget {
  const WorkersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    return AlertDialog(
      title: const Text('Workers'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 540),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: controller.workerConfigs.map((worker) {
              final hired = controller.isWorkerHired(worker.id);
              final level = controller.workerLevel(worker.id);
              final upgradeCost = controller.workerUpgradeCost(worker.id);
              final canHire = !hired && state.coins >= worker.hireCost;
              final canUpgrade = hired && state.coins >= upgradeCost;
              return Card(
                child: ListTile(
                  title: Text(worker.name),
                  subtitle: Text(
                    '${worker.assignedStationId} | ${hired ? 'Lv $level' : 'Hire ${NumberFormatter.compact(worker.hireCost)}'}',
                  ),
                  trailing: hired
                      ? FilledButton.tonal(
                          onPressed: canUpgrade ? () => controller.upgradeWorker(worker.id) : null,
                          child: Text('Upgrade ${NumberFormatter.compact(upgradeCost)}'),
                        )
                      : FilledButton.tonal(
                          onPressed: canHire ? () => controller.hireWorker(worker.id) : null,
                          child: const Text('Hire'),
                        ),
                ),
              );
            }).toList(growable: false),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
