import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/store_product_configs.dart';
import '../../utils/number_formatter.dart';
import '../boosts/boost_panel.dart';
import '../game/game_controller.dart';
import '../game/widgets/game_dialogs.dart';

class StorePanel extends ConsumerWidget {
  const StorePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    return AlertDialog(
      title: const Text('Store'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gems: ${NumberFormatter.whole(state.gems)}', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              _sectionTitle(context, 'Free Rewards'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () => controller.watchAdForInstantCoins(),
                        child: const Text('Watch Ad: Instant Coins'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => controller.watchAdForGems(),
                        child: Text('Watch Ad: +${controller.rewardedGemAmount} Gems'),
                      ),
                    ],
                  ),
                ),
              ),
              _sectionTitle(context, 'Boosts'),
              Card(
                child: ListTile(
                  title: const Text('Temporary Boosts'),
                  subtitle: const Text('Income, production, and customer rush boosts'),
                  trailing: FilledButton.tonal(
                    onPressed: () => showGameDialog<void>(
                      context: context,
                      builder: (_) => const BoostPanel(),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
              _sectionTitle(context, 'Gems'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: state.gems >= controller.coinPackSmallGemCost
                            ? () async {
                                final ok = await showGameDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Buy Coin Pack'),
                                    content: Text(
                                      'Spend ${controller.coinPackSmallGemCost} gems for a small coin pack?',
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Buy')),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  controller.purchaseCoinPackSmallWithGems();
                                }
                              }
                            : null,
                        child: Text('Small Coin Pack (${controller.coinPackSmallGemCost} Gems)'),
                      ),
                      const FilledButton.tonal(
                        onPressed: null,
                        child: Text('Gem Packs Coming Soon'),
                      ),
                    ],
                  ),
                ),
              ),
              _sectionTitle(context, 'Starter Pack'),
              Card(
                child: Column(
                  children: storeProducts
                      .map(
                        (product) => ListTile(
                          title: Text(product.title),
                          subtitle: Text('Mock / Coming Soon  -  ${product.mockPriceLabel}'),
                          trailing: FilledButton.tonal(
                            onPressed: () => controller.purchaseMockStoreProduct(product.id),
                            child: const Text('Mock Buy'),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              _sectionTitle(context, 'Live Features'),
              const Card(
                child: ListTile(
                  title: Text('Leaderboards'),
                  subtitle: Text('Global ranking and seasonal ladders.'),
                  trailing: Chip(label: Text('Coming Soon')),
                ),
              ),
              const Card(
                child: ListTile(
                  title: Text('Social & Clubs'),
                  subtitle: Text('Friends, gifting, and cafe social systems.'),
                  trailing: Chip(label: Text('Coming Soon')),
                ),
              ),
            ],
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
