import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/chef_gear_catalog.dart';
import '../../../data/limited_event_configs.dart';
import '../../../data/shop_tier_configs.dart';
import '../game_controller.dart';
import '../../../utils/number_formatter.dart';

class DebugPanel extends ConsumerWidget {
  const DebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    return AlertDialog(
      title: const Text('Developer / Debug'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Coins: ${NumberFormatter.compact(state.coins)}'),
              Text('Cups: ${NumberFormatter.compact(state.coffeeCups)}'),
              Text('Customers served: ${state.lifetimeCustomersServed}'),
              Text('Save version: ${state.saveVersion}'),
              () {
                final tier = state.shopTier.currentTier;
                final cfg = shopTierConfigs.firstWhere((c) => c.tier == tier);
                final next = tier < 6
                    ? shopTierConfigs.firstWhere((c) => c.tier == tier + 1)
                    : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shop tier: $tier — ${cfg.name} (${cfg.globalEarningsMultiplier}x, max ${cfg.maxActiveStations} stations)'),
                    Text(next != null
                        ? 'Next tier cost: ${NumberFormatter.compact(next.upgradeCost)} coins'
                        : 'Shop tier: MAX'),
                  ],
                );
              }(),
              Text('Active customers: ${state.waitingCustomers}'),
              Text('Coins/sec: ${NumberFormatter.compact(controller.totalCoinsPerSecond)}'),
              Text('Prestige points: ${state.prestigePoints}'),
              Text('Gems: ${NumberFormatter.whole(state.gems)}'),
              Text('Event beans: ${state.eventBeans}'),
              Text('Theme: ${state.selectedThemeId}'),
              Text('Cloud sync: ${controller.cloudSyncState.lastSyncStatus}'),
              Text('Queued economy snapshots: ${controller.queuedEconomySnapshots}'),
              Text('Remote overrides: ${controller.remoteConfigOverrides.length}'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () => controller.addDebugCoins(1000),
                    child: const Text('Add 1,000 Coins'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.addDebugCups(100),
                    child: const Text('Add 100 Cups'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.addDebugGems(25),
                    child: const Text('Add 25 Gems'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.addDebugPrestigePoints(10),
                    child: const Text('Add 10 Prestige'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.clearQueue(),
                    child: const Text('Clear Queue'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.clearActiveBoosts(),
                    child: const Text('Clear Boosts'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.forceSave(),
                    child: const Text('Force Save'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.simulateOfflineHour(),
                    child: const Text('Simulate 1h Offline'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.fastForwardTimeSeconds(1800),
                    child: const Text('Fast Forward 30m'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.simulateCloudSync(),
                    child: const Text('Simulate Cloud Sync'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.simulateRemoteConfigOverride(
                      key: 'ads.rewarded_gem_amount',
                      value: 15,
                    ),
                    child: const Text('Simulate RC Override'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.addEventBeansDebug(50),
                    child: const Text('Add 50 Beans'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.simulateLiveEvent(),
                    child: const Text('Simulate Event'),
                  ),
                  for (final event in limitedEventConfigs)
                    FilledButton.tonal(
                      onPressed: () => controller.setLimitedEventActive(
                        event.id,
                        !state.activeEvents.activeEventIds.contains(event.id),
                      ),
                      child: Text(
                        state.activeEvents.activeEventIds.contains(event.id)
                            ? 'Disable ${event.title}'
                            : 'Enable ${event.title}',
                      ),
                    ),
                  FilledButton.tonal(
                    onPressed: () => controller.debugEquipGear(
                      hatId: chefHats.first.id,
                      shirtId: chefShirts.first.id,
                      pantsId: chefPants.first.id,
                      shoesId: chefShoes.first.id,
                    ),
                    child: const Text('Equip Full Gear Set'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => controller.debugEquipGear(
                      clearHat: true,
                      clearShirt: true,
                      clearPants: true,
                      clearShoes: true,
                    ),
                    child: const Text('Unequip All Gear'),
                  ),
                  FilledButton.tonal(
                    onPressed: state.shopTier.currentTier < 6
                        ? () => controller.upgradeShopTier()
                        : null,
                    child: Text(state.shopTier.currentTier < 6
                        ? 'Upgrade Shop Tier (→ Tier ${state.shopTier.currentTier + 1})'
                        : 'Shop Tier MAX'),
                  ),
                ],
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
}
