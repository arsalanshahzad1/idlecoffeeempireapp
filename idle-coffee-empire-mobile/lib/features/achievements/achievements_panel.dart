import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';

class AchievementsPanel extends ConsumerWidget {
  const AchievementsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final items = controller.achievements;

    return AlertDialog(
      title: const Text('Achievements'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 540),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              return Card(
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
                          onPressed: item.completed
                              ? () { HapticFeedback.mediumImpact(); controller.claimAchievement(item.config.id); }
                              : null,
                          child: const Text('Claim'),
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
