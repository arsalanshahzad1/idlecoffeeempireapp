import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event_shop_configs.dart';
import '../game/game_controller.dart';

class EventShopPanel extends ConsumerWidget {
  const EventShopPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    return AlertDialog(
      title: const Text('Event Shop'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Beans: ${state.eventBeans}'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: eventShopProducts.map((product) {
                  return ListTile(
                    title: Text(product.title),
                    subtitle: Text('Cost ${product.costEventBeans} beans'),
                    trailing: FilledButton.tonal(
                      onPressed: state.eventBeans >= product.costEventBeans
                          ? () => controller.purchaseEventShopProduct(product.id)
                          : null,
                      child: const Text('Buy'),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
