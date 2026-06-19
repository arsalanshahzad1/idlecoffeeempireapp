import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';
import '../../utils/number_formatter.dart';

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
                    ? 'Ready to prestige for a permanent boost.'
                    : 'Keep expanding and serving to earn your next prestige point.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              const Text('On Prestige Reset:'),
              const Text('Resets current run progress, stations, workers, decorations, managers, milestones, and run XP.'),
              const Text('Keeps prestige points, lifetime prestige, permanent upgrades, and prestige achievements.'),
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
                            onClaim: () {
                              Navigator.of(overlayCtx).pop();
                              controller.performPrestigeReset().then((_) {
                                if (context.mounted) Navigator.of(context).pop();
                              });
                            },
                          ),
                        );
                      }
                    : null,
                child: Text(canPrestige ? 'Prestige (+$potential)' : 'Prestige (Unavailable)'),
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
// Full-screen celebration overlay shown before prestige reset is committed.
// ---------------------------------------------------------------------------

class _PrestigeCelebrationOverlay extends StatefulWidget {
  const _PrestigeCelebrationOverlay({
    required this.points,
    required this.nextMultiplier,
    required this.onClaim,
  });

  final int points;
  final double nextMultiplier;
  final VoidCallback onClaim;

  @override
  State<_PrestigeCelebrationOverlay> createState() => _PrestigeCelebrationOverlayState();
}

class _PrestigeCelebrationOverlayState extends State<_PrestigeCelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _buttonCtrl;

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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _bgCtrl,
      child: Material(
        color: Colors.black87,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.18).animate(
                      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
                    ),
                    child: const Icon(Icons.emoji_events, size: 96, color: Color(0xFFFFD700)),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '🏆 +${widget.points} Prestige Points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Revenue x${widget.nextMultiplier.toStringAsFixed(2)} forever',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 56),
                  FadeTransition(
                    opacity: _buttonCtrl,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                        CurvedAnimation(parent: _buttonCtrl, curve: Curves.easeOutBack),
                      ),
                      child: FilledButton(
                        onPressed: () { HapticFeedback.heavyImpact(); widget.onClaim(); },
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
                        child: const Text('CLAIM & RESTART'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
