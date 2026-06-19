import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';

class MilestonesPanel extends ConsumerWidget {
  const MilestonesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final milestones = controller.milestones;

    return AlertDialog(
      title: const Text('Milestones'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 540),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: milestones
                .map(
                  (item) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.config.title, style: Theme.of(context).textTheme.titleSmall),
                          Text(item.config.description),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(value: item.progressRatio),
                          const SizedBox(height: 4),
                          Text('${item.progressValue}/${item.config.targetValue}'),
                          const SizedBox(height: 6),
                          Text(
                            'Reward: +${item.config.rewardCoins.toStringAsFixed(0)} coins, +${item.config.rewardXp} XP',
                          ),
                          const SizedBox(height: 6),
                          if (item.claimed)
                            const Text('Claimed')
                          else
                            FilledButton.tonal(
                              onPressed: item.claimable
                                  ? () {
                                      HapticFeedback.mediumImpact();
                                      controller.claimMilestone(item.config.id);
                                    }
                                  : null,
                              child: const Text('Claim'),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
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
