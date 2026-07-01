import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/city_configs.dart';
import '../../models/city_config.dart';
import '../../models/gear_item.dart';
import '../../utils/number_formatter.dart';
import '../../visuals/svg_canvas_widget.dart';
import '../game/game_controller.dart';

class PrestigePanel extends ConsumerWidget {
  const PrestigePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gameControllerProvider.notifier);
    final state = ref.watch(gameControllerProvider);
    final potential = controller.potentialPrestigePoints;
    final currentMultiplier = controller.currentPrestigeMultiplier;
    final nextMultiplier = controller.nextPrestigeMultiplier;
    final canPrestige = controller.canPrestige;
    final permanentUpgrades = controller.permanentUpgrades;
    final prestigeAchievements = controller.prestigeAchievements;

    return AlertDialog(
      title: const Text('Prestige'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 540),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current prestige points: ${state.prestigePoints}'),
              Text('Lifetime prestige points: ${state.lifetimePrestigePoints}'),
              Text('Total prestiges: ${state.prestigeCount}'),
              Text('Potential prestige points: $potential'),
              Text(
                'Multiplier: x${currentMultiplier.toStringAsFixed(2)} -> x${nextMultiplier.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: canPrestige ? 1 : (controller.prestigeMultiplierEstimate / (currentMultiplier + 1)).clamp(0.0, 0.95),
              ),
              const SizedBox(height: 4),
              Text(
                canPrestige
                    ? 'Ready to move to a new city.'
                    : 'Keep expanding and serving to earn your next prestige point.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              const Text('Moving to a New City:'),
              const Text(
                'Your shop resets to a roadside stall (Tier 1). Stations, workers, decorations, managers, milestones, and run XP start fresh in the new city.',
              ),
              const Text(
                'Your coins and lifetime stats are kept. Your chef earns a new piece of gear.',
              ),
              const Text(
                'Prestige points, permanent upgrades, and achievements carry over.',
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: canPrestige
                    ? () {
                        showGeneralDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          barrierLabel: '',
                          barrierColor: Colors.transparent,
                          transitionDuration: Duration.zero,
                          transitionBuilder: (ctx, a1, a2, child) => child,
                          pageBuilder: (overlayCtx, _, __) => _PrestigeCelebrationOverlay(
                            points: potential,
                            nextMultiplier: nextMultiplier,
                            nextCity: cityForLevel(state.cityLevel + 1),
                            onPrestige: () async {
                              await controller.performPrestigeReset();
                            },
                            onDone: () {
                              Navigator.of(overlayCtx).pop();
                              if (context.mounted) Navigator.of(context).pop();
                            },
                          ),
                        );
                      }
                    : null,
                child: Text(canPrestige ? 'Move to New City (+$potential PP)' : 'Prestige (Unavailable)'),
              ),
              const SizedBox(height: 14),
              const Text('Permanent Upgrades'),
              const SizedBox(height: 6),
              ...permanentUpgrades.map((item) {
                return Card(
                  child: ListTile(
                    title: Text(item.config.title),
                    subtitle: Text(
                      '${item.config.description} | Cost ${item.config.costPrestigePoints} PP',
                    ),
                    trailing: item.owned
                        ? const Text('Owned')
                        : FilledButton.tonal(
                            onPressed: state.prestigePoints >= item.config.costPrestigePoints
                                ? () => controller.purchasePermanentUpgrade(item.config.id)
                                : null,
                            child: const Text('Buy'),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Text('Prestige Achievements'),
              const SizedBox(height: 6),
              ...prestigeAchievements.map((item) {
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
                        const SizedBox(height: 4),
                        Text(
                          'Reward: +${NumberFormatter.compact(item.config.rewardCoins)} coins, +${item.config.rewardXp} XP, +${item.config.rewardPrestigePoints} PP',
                        ),
                        const SizedBox(height: 6),
                        if (item.claimed)
                          const Text('Claimed')
                        else
                          FilledButton.tonal(
                            onPressed: item.completed
                                ? () => controller.claimPrestigeAchievement(item.config.id)
                                : null,
                            child: const Text('Claim'),
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

// ---------------------------------------------------------------------------
// Full-screen celebration overlay — confirm phase before prestige runs, then
// a revealed phase that shows the gear reward after it completes.
// ---------------------------------------------------------------------------

class _PrestigeCelebrationOverlay extends ConsumerStatefulWidget {
  const _PrestigeCelebrationOverlay({
    required this.points,
    required this.nextMultiplier,
    required this.nextCity,
    required this.onPrestige,
    required this.onDone,
  });

  final int points;
  final double nextMultiplier;
  final CityConfig nextCity;
  final Future<void> Function() onPrestige;
  final VoidCallback onDone;

  @override
  ConsumerState<_PrestigeCelebrationOverlay> createState() =>
      _PrestigeCelebrationOverlayState();
}

class _PrestigeCelebrationOverlayState
    extends ConsumerState<_PrestigeCelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _buttonCtrl;

  bool _loading = false;
  GearItem? _droppedGear;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _buttonCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    // Delay button appearance to prevent accidental taps.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _buttonCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _pulseCtrl.dispose();
    _buttonCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleClaim() async {
    HapticFeedback.heavyImpact();
    setState(() => _loading = true);
    await widget.onPrestige();
    if (!mounted) return;
    final ownedGear = ref.read(gameControllerProvider).ownedGear;
    final gear = ownedGear.isNotEmpty ? ownedGear.last : null;
    setState(() {
      _loading = false;
      _droppedGear = gear;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.nextCity.accentColor;
    return FadeTransition(
      opacity: _bgCtrl,
      child: Material(
        color: Colors.black87,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [
                accentColor.withValues(alpha: 0.18),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _droppedGear != null
                    ? _buildRevealedContent()
                    : _buildConfirmContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.18).animate(
            CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
          ),
          child: const SvgCanvasWidget('decor/prestige_trophy.svg', size: 96),
        ),
        const SizedBox(height: 28),
        Text(
          'Move to ${widget.nextCity.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          widget.nextCity.description,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Text(
          '🏆 +${widget.points} Prestige Points',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Revenue x${widget.nextMultiplier.toStringAsFixed(2)} forever',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Your coins and lifetime stats are kept.\nShop resets to Tier 1. Chef earns new gear.',
          style: TextStyle(color: Colors.white60, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 56),
        if (_loading)
          const CircularProgressIndicator(color: Color(0xFFFFD700))
        else
          FadeTransition(
            opacity: _buttonCtrl,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                CurvedAnimation(parent: _buttonCtrl, curve: Curves.easeOutBack),
              ),
              child: FilledButton(
                onPressed: _handleClaim,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black87,
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('MOVE TO ${widget.nextCity.name.toUpperCase()}'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRevealedContent() {
    final gear = _droppedGear!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SvgCanvasWidget('decor/prestige_trophy.svg', size: 80),
        const SizedBox(height: 24),
        Text(
          'Welcome to ${widget.nextCity.name}!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          widget.nextCity.description,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Text(
          '🏆 +${widget.points} Prestige Points',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Revenue x${widget.nextMultiplier.toStringAsFixed(2)} forever',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _GearRewardCard(gear: gear),
        const SizedBox(height: 40),
        FilledButton(
          onPressed: widget.onDone,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black87,
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('CONTINUE TO NEW CITY'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Gear reward card — shown in the revealed phase after prestige completes.
// ---------------------------------------------------------------------------

class _GearRewardCard extends StatelessWidget {
  const _GearRewardCard({required this.gear});
  final GearItem gear;

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor(gear.rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'GEAR REWARD',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  gear.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RarityChip(rarity: gear.rarity),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '+${_pct(gear.speedBonus)}% speed  ·  +${_pct(gear.tipBonus)}% tips',
            style: const TextStyle(
              color: Color(0xFF66BB6A),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers — mirrors the pattern from chef_gear_screen.dart.
// ---------------------------------------------------------------------------

Color _rarityColor(GearRarity rarity) => switch (rarity) {
  GearRarity.common    => Colors.grey,
  GearRarity.rare      => Colors.blue,
  GearRarity.epic      => Colors.purple,
  GearRarity.legendary => const Color(0xFFFFB300),
};

String _rarityLabel(GearRarity rarity) => switch (rarity) {
  GearRarity.common    => 'Common',
  GearRarity.rare      => 'Rare',
  GearRarity.epic      => 'Epic',
  GearRarity.legendary => 'Legendary',
};

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

String _pct(double v) => (v * 100).toStringAsFixed(0);
