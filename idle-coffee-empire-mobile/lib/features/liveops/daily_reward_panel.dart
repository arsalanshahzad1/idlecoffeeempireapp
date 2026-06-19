import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daily_reward_config.dart';
import '../game/game_controller.dart';

class DailyRewardPanel extends ConsumerWidget {
  const DailyRewardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final canClaim = controller.canClaimDailyReward();
    return AlertDialog(
      title: const Text('Daily Reward'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: dailyRewardCycleConfig.rewards.length,
                itemBuilder: (context, index) {
                  final reward = dailyRewardCycleConfig.rewards[index];
                  final isCurrent = state.dailyReward.currentDayIndex == index;
                  return ListTile(
                    title: Text('Day ${reward.day}'),
                    subtitle: Text('Coins ${reward.coins.toStringAsFixed(0)} | Gems ${reward.gems}${reward.prestigePoints > 0 ? ' | Prestige ${reward.prestigePoints}' : ''}'),
                    trailing: isCurrent ? const Chip(label: Text('Today')) : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: canClaim ? () => controller.claimDailyReward() : null,
              child: Text(canClaim ? 'Claim Reward' : 'Already Claimed Today'),
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
