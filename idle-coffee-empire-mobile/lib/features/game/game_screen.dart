import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

import '../../data/station_configs.dart';
import '../../game/idle_coffee_game.dart';
import '../../managers/economy_manager.dart';
import '../../utils/number_formatter.dart';
import '../../visuals/visual_config.dart';
import 'game_controller.dart';
import 'game_state.dart';
import 'widgets/game_dialogs.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/queue_panel.dart';
import 'widgets/station_detail_panel.dart';
import '../boosts/boost_panel.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with SingleTickerProviderStateMixin {
  IdleCoffeeGame? _game;
  Timer? _offlineBannerTimer;
  bool _showOfflineBanner = false;
  double _lastOfflineIncomeShown = 0;

  late final AnimationController _confettiCtrl;
  final _rng = math.Random();
  var _confettiParticles = <_ConfettiParticle>[];
  var _showConfetti = false;

  static const double _bottomPanelHeight = 154;
  static const _economy = EconomyManager();

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _offlineBannerTimer?.cancel();
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _triggerConfetti() {
    _confettiParticles = List.generate(30, (_) => _ConfettiParticle(_rng));
    setState(() => _showConfetti = true);
    _confettiCtrl.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(gameControllerProvider.notifier);
    final state = ref.watch(gameControllerProvider);
    _game ??= IdleCoffeeGame(controller: controller);

    ref.listen<GameState>(gameControllerProvider, (prev, next) {
      if (next.lastUiEvent == 'prestige_reset' &&
          (prev?.uiEventCounter ?? -1) != next.uiEventCounter) {
        _triggerConfetti();
      }
    });

    if (state.lastOfflineIncome > 0 && state.lastOfflineIncome != _lastOfflineIncomeShown) {
      _lastOfflineIncomeShown = state.lastOfflineIncome;
      _showOfflineBanner = true;
      _offlineBannerTimer?.cancel();
      _offlineBannerTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() => _showOfflineBanner = false);
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1F1713),
      body: Stack(
        children: [
          if (controller.loaded) GameWidget(game: _game!),
          if (!controller.loaded) const Center(child: CircularProgressIndicator()),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(state.uiEventCounter),
                duration: const Duration(milliseconds: 140),
                tween: Tween<double>(begin: 0.985, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: _buildTopHud(state, controller, context),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomPanel(context, controller, state),
            ),
          ),
          if (state.lastOfflineIncome > 0)
            Positioned(
              left: 12,
              right: 12,
              top: MediaQuery.paddingOf(context).top + 82,
              child: _buildOfflineBanner(state, controller),
            ),
          // Confetti burst on prestige reset — 30 colored circles animate
          // outward from screen centre over 1.5 s using a custom painter.
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiCtrl,
                  builder: (context, _) => CustomPaint(
                    painter: _ConfettiPainter(
                      _confettiParticles,
                      _confettiCtrl.value,
                      Offset(
                        MediaQuery.sizeOf(context).width / 2,
                        MediaQuery.sizeOf(context).height / 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopHud(GameState state, GameController controller, BuildContext context) {
    final activeBoosts = controller.activeBoosts();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: VisualConfig.hudBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(
          children: [
            // ── Left: coins + CPS ──────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB300),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x44000000), blurRadius: 6)],
                    ),
                    child: const Icon(Icons.monetization_on, color: Colors.white, size: 19),
                  ),
                  const SizedBox(width: 9),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        NumberFormatter.compact(state.coins),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        '${NumberFormatter.compact(controller.totalCoinsPerSecond)}/s',
                        style: const TextStyle(
                          color: VisualConfig.hudSubtext,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Center: active boost pill ──────────────────────────────────
            if (activeBoosts.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => _openDialog(context, const BoostPanel()),
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: VisualConfig.amber,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 6)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          _formatBoostTime(controller.boostRemainingSeconds(activeBoosts.last.boostId)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              const Spacer(flex: 3),
            const SizedBox(width: 8),
            // ── Right: gems + level badge + menu ──────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond_rounded, color: Color(0xFF4FC3F7), size: 15),
                    const SizedBox(width: 4),
                    Text(
                      NumberFormatter.whole(state.gems),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: VisualConfig.amber,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Lv ${state.playerLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            _buildSystemMenu(context, controller),
          ],
        ),
      ),
    );
  }

  String _formatBoostTime(int seconds) {
    if (seconds <= 0) return '0s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  Widget _buildSystemMenu(BuildContext context, GameController controller) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(onPressed: () => _openDialog(context, const SettingsDialog()), child: const Text('Settings')),
      ],
      builder: (context, menuController, child) {
        return IconButton.filledTonal(
          style: IconButton.styleFrom(
            backgroundColor: VisualConfig.coffeeBrown,
            foregroundColor: Colors.white,
            minimumSize: const Size(42, 42),
          ),
          onPressed: () => menuController.isOpen ? menuController.close() : menuController.open(),
          icon: const Icon(Icons.menu, size: 20),
        );
      },
    );
  }

  Widget _buildBottomPanel(BuildContext context, GameController controller, GameState state) {
    final selectedId = state.selectedStationId;
    if (selectedId != null && state.stations[selectedId] != null) {
      return SizedBox(
        height: _bottomPanelHeight,
        child: StationDetailPanel(
          key: ValueKey(selectedId),
          stationId: selectedId,
          onClose: controller.clearSelection,
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
      decoration: BoxDecoration(
        color: VisualConfig.panel,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: VisualConfig.panelBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x50000000), blurRadius: 18, offset: Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          _navButton(context, Icons.storefront_rounded, 'Stations', () => _showStationsSheet(context, controller)),
          _navButton(context, Icons.receipt_long_rounded, 'Orders', () => _showQueuePanel(context)),
          _navButton(context, Icons.settings_rounded, 'Settings', () => _openDialog(context, const SettingsDialog())),
        ],
      ),
    );
  }

  Widget _navButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () { HapticFeedback.selectionClick(); onPressed(); },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: VisualConfig.espressoBrown.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 26, color: VisualConfig.espressoBrown),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: VisualConfig.espressoBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<T?> _openDialog<T>(BuildContext context, Widget panel) {
    return showGameDialog<T>(context: context, builder: (_) => panel);
  }

  Future<void> _showQueuePanel(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QueuePanel(),
    );
  }

  Future<void> _showStationsSheet(BuildContext context, GameController controller) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(gameControllerProvider);
            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.72),
              decoration: const BoxDecoration(
                color: VisualConfig.panel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(width: 44, height: 4, decoration: BoxDecoration(color: VisualConfig.panelBorder, borderRadius: BorderRadius.circular(99))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                    child: Row(
                      children: [
                        Expanded(child: Text('Stations & Upgrades', style: Theme.of(context).textTheme.titleMedium)),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: stationConfigs.length,
                      itemBuilder: (context, index) {
                        final config = stationConfigs[index];
                        final station = state.stations[config.id];
                        if (station == null) {
                          return const SizedBox.shrink();
                        }
                        final upgradeCost = _economy.upgradeCost(config, station.level);
                        final queueCount = state.stationQueues[config.id]?.length ?? 0;
                        final canUpgrade = station.isUnlocked && station.level < 100 && state.coins >= upgradeCost;
                        final canUnlock = !station.isUnlocked && state.coins >= config.unlockCost;
                        return Card(
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor: station.isUnlocked ? VisualConfig.caramel : Colors.blueGrey,
                              child: Icon(station.isUnlocked ? Icons.local_cafe : Icons.lock, size: 18, color: Colors.white),
                            ),
                            title: Text(config.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              station.isUnlocked
                                  ? 'Lv ${station.level} | Queue $queueCount | Upgrade ${NumberFormatter.compact(upgradeCost)}'
                                  : 'Locked | Unlock ${NumberFormatter.compact(config.unlockCost)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: canUpgrade
                                  ? () => controller.upgradeStation(config.id)
                                  : (canUnlock ? () => controller.unlockStation(config.id) : null),
                              child: Text(station.isUnlocked ? 'Upgrade' : 'Unlock'),
                            ),
                            onTap: () {
                              controller.selectStation(config.id);
                              Navigator.of(sheetContext).pop();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOfflineBanner(GameState state, GameController controller) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 180),
      offset: _showOfflineBanner ? Offset.zero : const Offset(0, -0.12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _showOfflineBanner ? 1 : 0,
        child: Card(
          color: Colors.green.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.savings, size: 16, color: Color(0xFF1B5E20)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Offline Income +${NumberFormatter.compact(state.lastOfflineIncome)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                if (controller.isOfflineRewardAdAvailable())
                  FilledButton.tonal(
                    onPressed: controller.claimOfflineDoubleRewarded,
                    child: const Text('Watch Ad 2x'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

// ---------------------------------------------------------------------------
// Confetti primitives — pure Flutter, no packages.
// ---------------------------------------------------------------------------

const _kConfettiColors = [
  Color(0xFFFFD700), // gold
  Color(0xFFFF6B6B), // coral
  Color(0xFF4ECDC4), // teal
  Color(0xFF96CEB4), // sage
  Color(0xFFDDA0DD), // plum
  Color(0xFFFFB347), // orange
];

class _ConfettiParticle {
  _ConfettiParticle(math.Random rng)
      : angle = rng.nextDouble() * 2 * math.pi,
        speed = 90 + rng.nextDouble() * 160,
        radius = 4.0 + rng.nextDouble() * 5.0,
        color = _kConfettiColors[rng.nextInt(_kConfettiColors.length)];

  final double angle;
  final double speed;
  final double radius;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.progress, this.center);

  final List<_ConfettiParticle> particles;
  final double progress; // 0 → 1 over the animation duration
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final dist = p.speed * progress;
      final x = center.dx + math.cos(p.angle) * dist;
      final y = center.dy + math.sin(p.angle) * dist;
      final fade = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: fade);
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
