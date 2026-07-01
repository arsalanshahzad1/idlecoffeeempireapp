import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../managers/economy_manager.dart';
import '../../../utils/number_formatter.dart';
import '../game_controller.dart';

class StationDetailPanel extends ConsumerWidget {
  const StationDetailPanel({
    required this.stationId,
    required this.onClose,
    super.key,
  });

  final String stationId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gameControllerProvider.notifier);
    final state = ref.watch(gameControllerProvider);
    final station = state.stations[stationId];
    if (station == null) {
      return const SizedBox.shrink();
    }

    const economy = EconomyManager();
    final config = controller.configFor(stationId);
    final upgradeCost = economy.upgradeCost(config, station.level);
    final worker = controller.workerForStation(stationId);
    final workerHired = worker != null && controller.isWorkerHired(worker.id);
    final workerLevel = worker == null ? 1 : controller.workerLevel(worker.id);
    final workerUpgradeCost = worker == null ? 0.0 : controller.workerUpgradeCost(worker.id);
    final queueCount = state.stationQueues[stationId]?.length ?? 0;
    final activeSlots = controller.cookCountForStation(stationId);
    final isNearingSecondChef = station.isUnlocked &&
        activeSlots < 2 &&
        (config.secondChefUnlockLevel - station.level) <= 5;

    final canUnlock = !station.isUnlocked && state.coins >= config.unlockCost;
    final canUpgrade = station.isUnlocked && station.level < 100 && state.coins >= upgradeCost;
    final canHireCook = worker != null && !workerHired && station.isUnlocked && state.coins >= worker.hireCost;
    final canAddCook = worker != null && workerHired && workerLevel < 2 && state.coins >= workerUpgradeCost;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E7CE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7BFA3), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x44000000), blurRadius: 14, offset: Offset(0, -4)),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      config.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _statChip(Icons.trending_up, 'Lv ${station.level}/100'),
                  _statChip(Icons.group, 'Chefs $activeSlots/2'),
                  _statChip(Icons.receipt, 'Queue $queueCount'),
                  _statChip(Icons.timer, '${config.productionTimeSeconds.toStringAsFixed(1)}s each'),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: station.productionProgress),
              const SizedBox(height: 6),
              Text(
                station.blockedReason == null
                    ? (station.isProducing ? 'Cooking full order' : 'Waiting for order')
                    : station.blockedReason!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (isNearingSecondChef)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Reach level ${config.secondChefUnlockLevel} to add a second chef',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8B5E3C),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 7),
              if (!station.isUnlocked)
                FilledButton(
                  onPressed: canUnlock ? () => controller.unlockStation(stationId) : null,
                  child: Text('Unlock ${NumberFormatter.compact(config.unlockCost)}'),
                ),
              if (station.isUnlocked)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    FilledButton(
                      onPressed: canUpgrade ? () => controller.upgradeStation(stationId) : null,
                      child: Text(
                        station.level >= 100
                            ? 'Level Max'
                            : 'Upgrade ${NumberFormatter.compact(upgradeCost)}',
                      ),
                    ),
                    if (worker != null && !workerHired)
                      FilledButton.tonal(
                        onPressed: canHireCook ? () => controller.hireWorker(worker.id) : null,
                        child: Text('Add Cook ${NumberFormatter.compact(worker.hireCost)}'),
                      ),
                    if (worker != null && workerHired)
                      FilledButton.tonal(
                        onPressed: canAddCook ? () => controller.upgradeWorker(worker.id) : null,
                        child: Text(
                          workerLevel >= 2
                              ? 'Cooks Max'
                              : 'Add Cook ${NumberFormatter.compact(workerUpgradeCost)}',
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 15),
      label: Text(label),
    );
  }
}
