import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';
import '../../utils/number_formatter.dart';

class DecorationsPanel extends ConsumerWidget {
  const DecorationsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final items = controller.decorationConfigs;

    return AlertDialog(
      title: const Text('Decorations'),
      content: SizedBox(
        width: 440,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 540),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        'Cost ${NumberFormatter.compact(item.cost)} | Income x${item.incomeMultiplier.toStringAsFixed(2)} | Spawn x${item.spawnRateMultiplier.toStringAsFixed(2)} | Queue +${item.queueCapacityBonus}',
                      ),
                      trailing: state.purchasedDecorationIds.contains(item.id)
                          ? const Text('Owned')
                          : FilledButton.tonal(
                              onPressed: () => controller.purchaseDecoration(item.id),
                              child: const Text('Buy'),
                            ),
                    ),
                  ),
                )
                .toList(growable: false),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
