import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';
import '../../utils/number_formatter.dart';

class StatsPanel extends ConsumerWidget {
  const StatsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    return AlertDialog(
      title: const Text('Stats'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lifetime coins earned: ${NumberFormatter.compact(state.lifetimeCoinsEarned)}'),
              Text('Current coins/sec: ${NumberFormatter.compact(controller.totalCoinsPerSecond)}'),
              Text('Total customers served: ${state.lifetimeCustomersServed}'),
              Text('Cups produced: ${NumberFormatter.compact(state.lifetimeCupsProduced)}'),
              Text('Workers hired: ${state.workersHired.length}'),
              Text('Decorations purchased: ${state.purchasedDecorationIds.length}'),
              Text('Managers purchased: ${state.purchasedManagerIds.length}'),
              Text('Permanent upgrades: ${state.purchasedPermanentUpgradeIds.length}'),
              Text('Current expansion: ${controller.currentExpansion.name}'),
              Text('Player level: ${state.playerLevel}'),
              Text('Potential prestige points: ${controller.potentialPrestigePoints}'),
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
