import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';

class ManagersPanel extends ConsumerWidget {
  const ManagersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    return AlertDialog(
      title: const Text('Managers'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 540),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: controller.managerConfigs.map((item) {
              final owned = state.purchasedManagerIds.contains(item.id);
              final unlocked = controller.isManagerUnlocked(item.id);
              final reason = controller.managerUnlockReason(item.id);
              final canBuy = !owned && unlocked && reason == null;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.description} | Cost ${item.cost.toStringAsFixed(0)}'),
                        trailing: owned
                            ? const Text('Owned')
                            : FilledButton.tonal(
                                onPressed: canBuy ? () => controller.purchaseManager(item.id) : null,
                                child: Text(unlocked ? 'Buy' : 'Locked'),
                              ),
                      ),
                      if (reason != null) Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(reason),
                      ),
                    ],
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
