import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chef_gear_catalog.dart';
import '../../managers/chef_stat_manager.dart';
import '../../models/chef_state.dart';
import '../../models/gear_item.dart';
import '../../visuals/visual_config.dart';
import '../game/game_controller.dart';

// TODO(gear-shop): All items are freely equippable — no currency gate.
// A future "gear shop / unlock" phase should add acquisition flow here.

const _statManager = ChefStatManager();

const _slotLabel = <GearSlot, String>{
  GearSlot.hat:   'Hat',
  GearSlot.shirt: 'Shirt',
  GearSlot.pants: 'Pants',
  GearSlot.shoes: 'Shoes',
};

const _slotIcon = <GearSlot, IconData>{
  GearSlot.hat:   Icons.face_rounded,
  GearSlot.shirt: Icons.checkroom_rounded,
  GearSlot.pants: Icons.accessibility_new_rounded,
  GearSlot.shoes: Icons.directions_walk_rounded,
};

List<GearItem> _catalogItemsForSlot(GearSlot slot) => switch (slot) {
  GearSlot.hat   => chefHats,
  GearSlot.shirt => chefShirts,
  GearSlot.pants => chefPants,
  GearSlot.shoes => chefShoes,
};

String? _equippedId(ChefEquippedGear gear, GearSlot slot) => switch (slot) {
  GearSlot.hat   => gear.hatId,
  GearSlot.shirt => gear.shirtId,
  GearSlot.pants => gear.pantsId,
  GearSlot.shoes => gear.shoesId,
};

ChefEquippedGear _withSlot(ChefEquippedGear gear, GearSlot slot, String? id) =>
    switch (slot) {
      GearSlot.hat   => id != null ? gear.copyWith(hatId: id)   : gear.copyWith(clearHat: true),
      GearSlot.shirt => id != null ? gear.copyWith(shirtId: id) : gear.copyWith(clearShirt: true),
      GearSlot.pants => id != null ? gear.copyWith(pantsId: id) : gear.copyWith(clearPants: true),
      GearSlot.shoes => id != null ? gear.copyWith(shoesId: id) : gear.copyWith(clearShoes: true),
    };

Color _rarityColor(GearRarity rarity) => switch (rarity) {
  GearRarity.common    => Colors.grey,
  GearRarity.rare      => Colors.blue,
  GearRarity.epic      => Colors.purple,
  GearRarity.legendary => VisualConfig.amber,
};

String _rarityLabel(GearRarity rarity) => switch (rarity) {
  GearRarity.common    => 'Common',
  GearRarity.rare      => 'Rare',
  GearRarity.epic      => 'Epic',
  GearRarity.legendary => 'Legendary',
};

// ──────────────────────────────────────────────────────────────────────────────
// Main screen — opened as an AlertDialog via showGameDialog
// ──────────────────────────────────────────────────────────────────────────────

class ChefGearScreen extends ConsumerWidget {
  const ChefGearScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final chef = state.chefs['chef_1'] ?? ChefState.starter;
    final ownedGear = state.ownedGear;
    final stats = _statManager.computeStats(chef, ownedGear: ownedGear);
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Chef Gear', style: theme.textTheme.titleLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _StatBar(stats: stats),
            const SizedBox(height: 16),
            for (final slot in GearSlot.values) ...[
              _SlotCard(
                slot: slot,
                chef: chef,
                ownedGear: ownedGear,
                onTap: () => _openPicker(context, slot, chef, ownedGear),
              ),
              const SizedBox(height: 8),
            ],
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

  void _openPicker(BuildContext context, GearSlot slot, ChefState chef, List<GearItem> ownedGear) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GearPickerSheet(slot: slot, chef: chef, ownedGear: ownedGear),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Slot card — shows equipped item or empty placeholder
// ──────────────────────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.chef,
    required this.ownedGear,
    required this.onTap,
  });

  final GearSlot slot;
  final ChefState chef;
  final List<GearItem> ownedGear;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final equippedId = _equippedId(chef.equippedGear, slot);
    final item = equippedId != null ? resolveGearItem(equippedId, ownedGear) : null;
    final theme = Theme.of(context);
    final hasItem = item != null;

    return InkWell(
      borderRadius: BorderRadius.circular(VisualConfig.radiusMd),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasItem
              ? VisualConfig.espressoBrown.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(VisualConfig.radiusMd),
          border: Border.all(
            color: hasItem
                ? VisualConfig.panelBorder
                : VisualConfig.panelBorder.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: VisualConfig.espressoBrown.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _slotIcon[slot],
                size: 22,
                color: VisualConfig.espressoBrown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _slotLabel[slot]!.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: VisualConfig.espressoBrown.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item?.name ?? '— Empty —',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: hasItem
                                ? VisualConfig.espressoBrown
                                : VisualConfig.espressoBrown.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      if (item != null) ...[
                        const SizedBox(width: 6),
                        _RarityChip(rarity: item.rarity),
                      ],
                    ],
                  ),
                  if (item != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '+${_pct(item.speedBonus)}% speed  ·  +${_pct(item.tipBonus)}% tips',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: VisualConfig.successGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: VisualConfig.panelBorder,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Gear picker bottom sheet
// ──────────────────────────────────────────────────────────────────────────────

class _GearPickerSheet extends ConsumerStatefulWidget {
  const _GearPickerSheet({
    required this.slot,
    required this.chef,
    required this.ownedGear,
  });

  final GearSlot slot;
  final ChefState chef;
  final List<GearItem> ownedGear;

  @override
  ConsumerState<_GearPickerSheet> createState() => _GearPickerSheetState();
}

class _GearPickerSheetState extends ConsumerState<_GearPickerSheet> {
  late String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = _equippedId(widget.chef.equippedGear, widget.slot);
  }

  ChefStats _previewStats() {
    final previewGear = _withSlot(widget.chef.equippedGear, widget.slot, _selectedId);
    return _statManager.computeStats(
      widget.chef.copyWith(equippedGear: previewGear),
      ownedGear: widget.ownedGear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogItems = _catalogItemsForSlot(widget.slot);
    final ownedForSlot = widget.ownedGear.where((g) => g.slot == widget.slot).toList();
    final currentId = _equippedId(widget.chef.equippedGear, widget.slot);
    final preview = _previewStats();
    final unchanged = _selectedId == currentId;

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      decoration: const BoxDecoration(
        color: VisualConfig.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: VisualConfig.panelBorder,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select ${_slotLabel[widget.slot]}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: _StatBar(stats: preview, isPreview: true),
          ),
          const Divider(height: 1, thickness: 1),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              children: [
                _GearOption(
                  name: 'None (remove)',
                  speedBonus: 0,
                  tipBonus: 0,
                  rarity: null,
                  isSelected: _selectedId == null,
                  isCurrentlyEquipped: currentId == null,
                  onTap: () => setState(() => _selectedId = null),
                ),
                const SizedBox(height: 4),
                for (final item in catalogItems) ...[
                  _GearOption(
                    name: item.name,
                    speedBonus: item.speedBonus,
                    tipBonus: item.tipBonus,
                    rarity: item.rarity,
                    isSelected: _selectedId == item.id,
                    isCurrentlyEquipped: currentId == item.id,
                    onTap: () => setState(() => _selectedId = item.id),
                  ),
                  const SizedBox(height: 4),
                ],
                if (ownedForSlot.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 8, 2, 4),
                    child: Text(
                      'YOUR GEAR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: VisualConfig.espressoBrown.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  for (final item in ownedForSlot) ...[
                    _GearOption(
                      name: item.name,
                      speedBonus: item.speedBonus,
                      tipBonus: item.tipBonus,
                      rarity: item.rarity,
                      isSelected: _selectedId == item.id,
                      isCurrentlyEquipped: currentId == item.id,
                      onTap: () => setState(() => _selectedId = item.id),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: unchanged ? null : _confirm,
                  child: Text(_selectedId == null ? 'Remove' : 'Equip'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirm() {
    final controller = ref.read(gameControllerProvider.notifier);
    if (_selectedId != null) {
      controller.equipGear('chef_1', widget.slot, _selectedId!);
    } else {
      controller.unequipGear('chef_1', widget.slot);
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ──────────────────────────────────────────────────────────────────────────────

class _StatBar extends StatelessWidget {
  const _StatBar({required this.stats, this.isPreview = false});

  final ChefStats stats;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final speedPct = _pct(stats.speedMultiplier - 1.0);
    final tipPct = _pct(stats.tipMultiplier - 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: VisualConfig.espressoBrown.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(VisualConfig.radiusSm),
      ),
      child: Row(
        children: [
          if (isPreview) ...[
            const Text(
              'Preview  ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: VisualConfig.amber,
              ),
            ),
          ],
          const Icon(Icons.bolt_rounded, color: VisualConfig.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            '+$speedPct% speed',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.attach_money_rounded,
            color: VisualConfig.successGreen,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '+$tipPct% tips',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _RarityChip extends StatelessWidget {
  const _RarityChip({required this.rarity});

  final GearRarity rarity;

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor(rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _rarityLabel(rarity),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _GearOption extends StatelessWidget {
  const _GearOption({
    required this.name,
    required this.speedBonus,
    required this.tipBonus,
    required this.rarity,
    required this.isSelected,
    required this.isCurrentlyEquipped,
    required this.onTap,
  });

  final String name;
  final double speedBonus;
  final double tipBonus;
  final GearRarity? rarity;
  final bool isSelected;
  final bool isCurrentlyEquipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStats = speedBonus > 0 || tipBonus > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(VisualConfig.radiusMd),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? VisualConfig.espressoBrown.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(VisualConfig.radiusMd),
          border: Border.all(
            color: isSelected
                ? VisualConfig.espressoBrown
                : VisualConfig.panelBorder.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? VisualConfig.espressoBrown
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? VisualConfig.espressoBrown
                      : VisualConfig.panelBorder,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(name, style: theme.textTheme.titleSmall)),
                      if (rarity != null) ...[
                        const SizedBox(width: 6),
                        _RarityChip(rarity: rarity!),
                      ],
                      if (isCurrentlyEquipped) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: VisualConfig.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'equipped',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: VisualConfig.amber,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasStats) ...[
                    const SizedBox(height: 2),
                    Text(
                      '+${_pct(speedBonus)}% speed  ·  +${_pct(tipBonus)}% tips',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: VisualConfig.successGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _pct(double v) => (v * 100).toStringAsFixed(0);
