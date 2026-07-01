import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/city_configs.dart';
import '../../data/shop_tier_configs.dart';
import '../../models/shop_tier_config.dart';
import '../../utils/number_formatter.dart';
import '../../visuals/visual_config.dart';
import '../game/game_controller.dart';

class ShopTierScreen extends ConsumerWidget {
  const ShopTierScreen({super.key});

  static const int _maxTier = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    final currentTierIndex = state.shopTier.currentTier - 1;
    final currentConfig = shopTierConfigs[currentTierIndex];
    final isMaxTier = state.shopTier.currentTier >= _maxTier;
    final nextConfig = isMaxTier ? null : shopTierConfigs[currentTierIndex + 1];
    final canAfford = nextConfig != null && state.coins >= nextConfig.upgradeCost;
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text('Your Shop', style: theme.textTheme.titleLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              cityForLevel(state.cityLevel).name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: VisualConfig.espressoBrown.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            // ── Current tier card ────────────────────────────────────────────
            _TierCard(config: currentConfig, isCurrent: true),
            const SizedBox(height: 14),

            // ── Next tier / max tier ─────────────────────────────────────────
            if (isMaxTier)
              _MaxTierBadge()
            else ...[
              _NextTierCard(
                config: nextConfig!,
                canAfford: canAfford,
                onUpgrade: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Upgrade Shop Tier?'),
                      content: const Text(
                        'Upgrading will reset your coins and all station progress. '
                        'Your chef, gear, and city stay the same.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Upgrade'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  HapticFeedback.mediumImpact();
                  await controller.upgradeShopTier();
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Current tier card
// ──────────────────────────────────────────────────────────────────────────────

class _TierCard extends StatelessWidget {
  const _TierCard({required this.config, required this.isCurrent});

  final ShopTierConfig config;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VisualConfig.espressoBrown.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(VisualConfig.radiusMd),
        border: Border.all(color: VisualConfig.panelBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: VisualConfig.amber,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Tier ${config.tier}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(config.name, style: theme.textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            config.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: VisualConfig.espressoBrown.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatChip(
                icon: Icons.trending_up_rounded,
                label: '${config.globalEarningsMultiplier.toStringAsFixed(1)}× earnings',
                color: VisualConfig.successGreen,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.storefront_rounded,
                label: 'Up to ${config.maxActiveStations} station${config.maxActiveStations == 1 ? '' : 's'}',
                color: VisualConfig.espressoBrown,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Next tier preview + upgrade button
// ──────────────────────────────────────────────────────────────────────────────

class _NextTierCard extends StatelessWidget {
  const _NextTierCard({
    required this.config,
    required this.canAfford,
    required this.onUpgrade,
  });

  final ShopTierConfig config;
  final bool canAfford;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: canAfford
            ? VisualConfig.successGreen.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(VisualConfig.radiusMd),
        border: Border.all(
          color: canAfford
              ? VisualConfig.successGreen.withValues(alpha: 0.5)
              : VisualConfig.panelBorder.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT UPGRADE',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: VisualConfig.espressoBrown.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: VisualConfig.espressoBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Tier ${config.tier}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: VisualConfig.espressoBrown,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(config.name, style: theme.textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            config.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: VisualConfig.espressoBrown.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatChip(
                icon: Icons.trending_up_rounded,
                label: '${config.globalEarningsMultiplier.toStringAsFixed(1)}× earnings',
                color: VisualConfig.successGreen,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.storefront_rounded,
                label: 'Up to ${config.maxActiveStations} stations',
                color: VisualConfig.espressoBrown,
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: canAfford ? onUpgrade : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upgrade_rounded, size: 18),
                const SizedBox(width: 6),
                Text('Upgrade — ${NumberFormatter.compact(config.upgradeCost)}'),
              ],
            ),
          ),
          if (!canAfford) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Need ${NumberFormatter.compact(config.upgradeCost)} coins',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: VisualConfig.espressoBrown.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Max tier badge
// ──────────────────────────────────────────────────────────────────────────────

class _MaxTierBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: VisualConfig.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(VisualConfig.radiusMd),
        border: Border.all(
          color: VisualConfig.amber.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, color: VisualConfig.amber, size: 22),
          SizedBox(width: 10),
          Text(
            'Max Tier Reached',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: VisualConfig.amber,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared stat chip
// ──────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(VisualConfig.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
