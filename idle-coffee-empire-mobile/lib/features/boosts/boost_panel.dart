import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/monetization_config.dart';
import '../../utils/number_formatter.dart';
import '../game/game_controller.dart';
import '../game/widgets/game_dialogs.dart';

class BoostPanel extends ConsumerWidget {
  const BoostPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final boosts = controller.boostConfigs;
    return AlertDialog(
      title: const Text('Boosts'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gems: ${NumberFormatter.whole(state.gems)}'),
              const SizedBox(height: 8),
              ...boosts.map((cfg) {
                final remaining = controller.boostRemainingSeconds(cfg.id);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cfg.title, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text('Duration: ${cfg.durationSeconds ~/ 60}m'),
                        if (cfg.incomeMultiplier > 1) Text('Income x${cfg.incomeMultiplier.toStringAsFixed(1)}'),
                        if (cfg.productionSpeedMultiplier > 1) Text('Production x${cfg.productionSpeedMultiplier.toStringAsFixed(1)}'),
                        if (cfg.spawnRateMultiplier > 1) Text('Customer Rush x${cfg.spawnRateMultiplier.toStringAsFixed(1)}'),
                        const SizedBox(height: 6),
                        if (remaining > 0) Text('Active: ${remaining}s left'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonal(
                              onPressed: () async {
                                final ok = await showGameDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Buy Boost'),
                                    content: Text('Spend ${cfg.gemCost} gems for ${cfg.title}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Buy')),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  HapticFeedback.mediumImpact();
                                  controller.purchaseBoostWithGems(cfg.id);
                                }
                              },
                              child: Text('Buy (${cfg.gemCost} Gems)'),
                            ),
                            if (cfg.id == MonetizationConfig.productionBoost.id)
                              FilledButton.tonal(
                                onPressed: () => controller.watchAdForSpeedBoost(),
                                child: const Text('Watch Ad'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
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
