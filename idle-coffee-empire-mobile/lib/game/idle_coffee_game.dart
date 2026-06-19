import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/coin_popup_component.dart';
import '../components/decoration_component.dart';
import '../components/station_component.dart';
import '../components/worker_component.dart';
import '../data/decoration_configs.dart';
import '../data/station_configs.dart';
import '../features/game/game_controller.dart';
import '../managers/economy_manager.dart';
import '../managers/customer_manager.dart';
import '../features/game/game_state.dart';
import '../models/station_state.dart';
import 'cafe_scene.dart';
import 'map_constants.dart';
import 'shop_zones.dart';
import '../visuals/render_layers.dart';
import '../data/theme_configs.dart';
import '../visuals/effect_helpers.dart';
import '../sprites/svg_sprite.dart';

class IdleCoffeeGame extends FlameGame {
  IdleCoffeeGame({required GameController controller}) : _controller = controller;

  final GameController _controller;
  final _stationComponents = <String, StationComponent>{};
  final _workerComponents = <String, WorkerComponent>{};
  final _decorationComponents = <String, DecorationComponent>{};
  final _stationPositions = <String, Vector2>{};
  final _tablePositions = <String, Vector2>{};

  World? _world;
  CafeScene? _cafeScene;
  _CounterReceptionTapZone? _counterTapZone;
  CustomerManager? _customerManager;
  String? _lastExpansionStageId;
  bool _initialized = false;
  int _lastServedCustomers = 0;
  double _lastTipsEarned = 0;
  int _lastUiEventCounter = 0;
  int _activePopups = 0;
  static const int _maxPopups = 20;
  static const _economy = EconomyManager();

  @override
  Future<void> onLoad() async {
    await SvgSprites.loadAll();
    final world = World();
    final scene = CafeScene(world: world);
    _world = world;
    _cafeScene = scene;
    _customerManager = CustomerManager(world: world);
    _counterTapZone = _CounterReceptionTapZone(
      onTap: (worldPos) {
        _controller.clearSelection();
      },
    );

    camera = CameraComponent(world: world);
    addAll([world, camera]);
    await world.add(scene);
    await world.add(_counterTapZone!);
    _spawnStations();
    _lastServedCustomers = _controller.currentState.servedCustomers;
    _lastTipsEarned = _controller.currentState.tipsEarned;
    _initialized = true;
    _relayout();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _controller.tick(dt);
    final gameState = _controller.currentState;
    _syncExpansionVisuals();
    _syncStationVisuals(gameState.stations);
    _syncDecorations();
    _syncWorkers();
    _syncUiEvents(gameState);
    _customerManager?.syncQueueTypes(gameState.waitingCustomerTypes);
    _customerManager?.syncCafeOrders(gameState.cafeOrders);
    _customerManager?.update(dt);
    _emitServiceFeedback(gameState.servedCustomers);
    _emitTipFeedback(gameState.tipsEarned);
  }

  void _emitServiceFeedback(int servedCustomers) {
    final delta = servedCustomers - _lastServedCustomers;
    _lastServedCustomers = servedCustomers;
    if (delta <= 0) {
      return;
    }
    final cashierPos = _stationPositions['cashier_counter'];
    if (cashierPos == null) {
      return;
    }
    _addPopup(
      position: cashierPos + Vector2(0, -26),
      amount: delta.toDouble(),
      color: Colors.orangeAccent,
      prefix: 'Served +',
    );
  }

  void _emitTipFeedback(double tipsEarned) {
    final delta = tipsEarned - _lastTipsEarned;
    _lastTipsEarned = tipsEarned;
    if (delta <= 0) {
      return;
    }
    final anchor = _tablePositions.values.isNotEmpty ? _tablePositions.values.first : (_stationPositions['cashier_counter'] ?? size / 2);
    _addPopup(
      position: anchor + Vector2(0, -34),
      amount: delta,
      color: Colors.lightGreenAccent,
      prefix: 'Tip +',
    );
  }

  void _syncExpansionVisuals() {
    final scene = _cafeScene;
    if (scene == null) {
      return;
    }
    final expansion = _controller.currentExpansion;
    if (_lastExpansionStageId == expansion.id) {
      return;
    }
    _lastExpansionStageId = expansion.id;
    final selectedTheme = liveThemeConfigs.firstWhere(
      (theme) => theme.id == _controller.currentState.selectedThemeId,
      orElse: () => liveThemeConfigs.first,
    );
    final expansionColor = Color(expansion.floorColorHex);
    final themeFloorTint = _hexColor(selectedTheme.floorTintHex);
    scene.setFloorColor(Color.lerp(expansionColor, themeFloorTint, 0.4) ?? expansionColor);
    final tier = switch (expansion.id) {
      'small_cart' => 0,
      'cozy_cafe' => 1,
      'busy_shop' => 2,
      'downtown_cafe' => 3,
      'premium_house' => 4,
      'empire_hq' => 5,
      _ => 0,
    };
    scene.setEvolutionTier(tier);
  }

  void _syncUiEvents(GameState gameState) {
    if (gameState.uiEventCounter == _lastUiEventCounter) {
      return;
    }
    _lastUiEventCounter = gameState.uiEventCounter;
    final event = gameState.lastUiEvent;
    final stationId = gameState.lastUiEventStationId;
    if (stationId != null) {
      final station = _stationComponents[stationId];
      if (station != null) {
        station.add(EffectHelpers.bounce(up: 3, inMs: 60, outMs: 120));
      }
    }
    if (event == 'milestone_claimed' || event == 'prestige_reset' || event == 'expansion_unlocked') {
      if (event == 'expansion_unlocked') HapticFeedback.heavyImpact();
      final anchor = _stationPositions['cashier_counter'] ?? size / 2;
      _addPopup(
        position: anchor + Vector2(0, -38),
        amount: 1,
        color: Colors.greenAccent,
        prefix: event == 'prestige_reset'
            ? 'Prestige!'
            : (event == 'expansion_unlocked' ? 'Expansion!' : 'Milestone!'),
      );
      if (event == 'prestige_reset') {
        _triggerPrestigeFlash();
        _emitPrestigePopups();
      }
    }
  }

  void _triggerPrestigeFlash() {
    add(_PrestigeFlashComponent(gameSize: size));
  }

  void _emitPrestigePopups() {
    final center = size / 2;
    final rng = math.Random();
    for (var i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * math.pi + rng.nextDouble() * 0.3;
      final dist = 30.0 + rng.nextDouble() * 90.0;
      _world?.add(
        CoinPopupComponent(
          position: center + Vector2(math.cos(angle) * dist, math.sin(angle) * dist),
          amount: 1,
          color: i.isEven ? const Color(0xFFFFD700) : Colors.lightGreenAccent,
          prefix: i.isEven ? '⭐' : '+',
        ),
      );
    }
  }

  void _syncDecorations() {
    final purchased = _controller.currentState.purchasedDecorationIds;
    var changed = false;

    final toRemove = _decorationComponents.keys.where((id) => !purchased.contains(id)).toList();
    for (final id in toRemove) {
      _decorationComponents.remove(id)?.removeFromParent();
      changed = true;
    }

    for (final cfg in decorationConfigs) {
      if (!purchased.contains(cfg.id) || _decorationComponents.containsKey(cfg.id)) continue;
      final comp = DecorationComponent(config: cfg, position: Vector2.zero(), purchased: true);
      _decorationComponents[cfg.id] = comp;
      _world?.add(comp);
      changed = true;
    }

    if (changed) _relayout();
  }

  void _spawnStations() {
    for (final config in stationConfigs) {
      final pos = Vector2.zero();
      final comp = StationComponent(
        config: config,
        state: _controller.currentState.stations[config.id] ??
            StationState(
              stationId: config.id,
              level: 1,
              isUnlocked: config.unlockCost == 0,
              autoEnabled: config.unlockCost == 0,
            ),
        position: pos,
        onTap: (stationId, worldPos) {
          final beforeState = _controller.currentState;
          final before = beforeState.coins;
          final cupsBefore = beforeState.coffeeCups;
          _controller.tapStation(stationId);
          _controller.selectStation(stationId);
          final afterState = _controller.currentState;
          final earned = (afterState.coins - before).clamp(0.0, double.infinity).toDouble();
          final cupsEarned =
              (afterState.coffeeCups - cupsBefore).clamp(0.0, double.infinity).toDouble();
          final servedNow = (afterState.servedCustomers - beforeState.servedCustomers).clamp(
            0,
            99,
          );
          if (_controller.settings.floatingTextEnabled && earned > 0) {
            _addPopup(position: worldPos, amount: earned);
          }
          if (_controller.settings.floatingTextEnabled && servedNow > 0) {
            _addPopup(
              position: worldPos + Vector2(0, -30),
              amount: servedNow.toDouble(),
              color: Colors.orangeAccent,
              prefix: 'Served +',
            );
          }
          if (_controller.settings.floatingTextEnabled && cupsEarned > 0) {
            _addPopup(
              position: worldPos + Vector2(0, -16),
              amount: cupsEarned,
              color: Colors.lightBlueAccent,
              prefix: '+',
            );
          }
        },
        showVisuals: _cafeScene?.usesFallbackMap ?? true,
      );
      _stationComponents[config.id] = comp;
      _world?.add(comp);
    }
  }

  void _syncStationVisuals(Map<String, StationState> states) {
    for (final entry in _stationComponents.entries) {
      final state = states[entry.key];
      if (state != null) {
        entry.value.applyState(state);
        final worker = _controller.workerForStation(entry.key);
        final hired = worker != null && _controller.isWorkerHired(worker.id);
        entry.value.setWorkerHired(hired);
        entry.value.setUpgradeAvailable(
          state.isUnlocked &&
              _controller.currentState.coins >=
                  _economy.upgradeCost(entry.value.config, state.level),
        );
        entry.value.setQueueCount(_controller.currentState.stationQueues[entry.key]?.length ?? 0);
      }
    }
  }

  void _syncWorkers() {
    final world = _world;
    if (world == null) {
      return;
    }

    for (final worker in _controller.currentState.workersHired) {
      if (_workerComponents.containsKey(worker)) {
        continue;
      }
      final workerConfig = _controller.workerById(worker);
      if (workerConfig == null) {
        continue;
      }
      final stationPos = _stationPositions[workerConfig.assignedStationId] ?? Vector2.zero();
      final offset = workerConfig.assignedStationId == 'cashier_counter'
          ? Vector2(0, 36)
          : Vector2(workerConfig.assignedStationId.contains('drive') ? -32 : 28, 8);
      final workerComp = WorkerComponent(
        workerId: worker,
        stationId: workerConfig.assignedStationId,
        position: stationPos + offset,
      );
      workerComp.setHome(stationPos + offset);
      _workerComponents[worker] = workerComp;
      workerComp.priority = RenderLayers.worker + (workerComp.position.y / 20).floor();
      world.add(workerComp);
    }
    for (final entry in _workerComponents.entries) {
      final workerConfig = _controller.workerById(entry.key);
      if (workerConfig == null) continue;
      final stationState = _controller.currentState.stations[workerConfig.assignedStationId];
      entry.value.setWorking(stationState?.isProducing ?? false);
      entry.value.deliverTo(_deliveryTargetForStation(workerConfig.assignedStationId));
      entry.value.priority = RenderLayers.worker + (entry.value.position.y / 20).floor();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _relayout();
  }

  void _relayout() {
    final world = _world;
    final cafeScene = _cafeScene;
    if (!_initialized || world == null || cafeScene == null) {
      return;
    }
    if (!world.isLoaded || _stationComponents.isEmpty) {
      return;
    }
    final viewSize = size;
    if (viewSize.x <= 0 || viewSize.y <= 0) {
      return;
    }
    camera.viewfinder.position = viewSize / 2;

    final usingFallbackMap = cafeScene.usesFallbackMap;
    final topHudReserve = viewSize.y < 720
        ? MapConstants.topHudReserveCompact
        : MapConstants.topHudReserveRegular;
    final bottomNavReserve = viewSize.y < 720
        ? MapConstants.bottomPanelReserveCompact
        : MapConstants.bottomPanelReserveRegular;
    final sideInset = usingFallbackMap
        ? (viewSize.x < 380 ? 6.0 : 10.0)
        : (viewSize.x < 380 ? 8.0 : MapConstants.screenPadding);
    final availableH = viewSize.y - topHudReserve - bottomNavReserve;
    late double floorW;
    late double floorH;
    late double floorLeft;
    late double floorTop;
    if (usingFallbackMap) {
      floorLeft = sideInset;
      floorTop = topHudReserve - (viewSize.y < 720 ? 4 : 8);
      floorW = viewSize.x - sideInset * 2;
      floorH = (viewSize.y - floorTop - 104).clamp(460.0, viewSize.y).toDouble();
    } else {
      final maxFloorW = (viewSize.x - sideInset * 2).clamp(
        MapConstants.minMapWidth,
        MapConstants.maxMapWidth,
      );
      final maxFloorH = availableH + 8;
      floorW = maxFloorW.toDouble();
      var resolvedFloorH = floorW / MapConstants.sourceAspectRatio;
      var resolvedFloorW = floorW;
      if (resolvedFloorH > maxFloorH) {
        resolvedFloorH = maxFloorH;
        resolvedFloorW = resolvedFloorH * MapConstants.sourceAspectRatio;
      }
      floorH = resolvedFloorH;
      floorLeft = (viewSize.x - resolvedFloorW) / 2;
      floorTop = topHudReserve + ((availableH - resolvedFloorH) / 2).clamp(0.0, 18.0).toDouble();
      floorW = resolvedFloorW;
    }
    final floorRight = floorLeft + floorW;
    final floorBottom = floorTop + floorH;
    final mapRect = Rect.fromLTRB(floorLeft, floorTop, floorRight, floorBottom);

    cafeScene.updateMapRect(mapRect);
    _counterTapZone?.layout(ShopZones.counterReceptionZone.resolveRect(mapRect));
    _stationPositions['cashier_counter'] = ShopZones.counterReceptionZone.resolveInteractionPoint(mapRect);

    for (final config in stationConfigs) {
      final zone = ShopZones.stationZoneFor(config.id);
      final pos = zone?.resolveInteractionPoint(mapRect) ??
          _stationAnchor(config.id, floorLeft, floorTop, floorW, floorH);
      _stationPositions[config.id] = pos;
      final station = _stationComponents[config.id];
      if (station != null) {
        station.position = pos;
        final zoneRect = zone?.resolveRect(mapRect);
        station.size = zoneRect == null
            ? Vector2.all((floorW * 0.13).clamp(46.0, 64.0).toDouble())
            : Vector2(
                (zoneRect.width * 0.72).clamp(54.0, 76.0).toDouble(),
                (zoneRect.height * 0.78).clamp(42.0, 58.0).toDouble(),
              );
        station.priority = RenderLayers.stationBase + (pos.y / 20).floor();
      }
    }

    _customerManager?.updateAnchors(
      spawnPoint: ShopZones.entranceZone.resolvePathPoint(mapRect),
      exitPoint: ShopZones.entranceZone.resolveInteractionPoint(mapRect),
      queueSlots: [
        _mapPoint(mapRect, 0.36, 0.35),
        _mapPoint(mapRect, 0.43, 0.35),
        _mapPoint(mapRect, 0.50, 0.35),
        _mapPoint(mapRect, 0.57, 0.35),
        _mapPoint(mapRect, 0.64, 0.35),
      ],
      tableSlots: _updateTablePositions(mapRect),
      fallbackWaitingSlot: ShopZones.customerQueueZone.resolvePathPoint(mapRect),
    );

    for (final entry in _workerComponents.entries) {
      final workerConfig = _controller.workerById(entry.key);
      if (workerConfig == null) {
        continue;
      }
      final stationPos = _stationPositions[workerConfig.assignedStationId];
      if (stationPos == null) {
        continue;
      }
      final offset = workerConfig.assignedStationId == 'cashier_counter'
          ? Vector2(0, 36)
          : Vector2(workerConfig.assignedStationId.contains('drive') ? -32 : 28, 8);
      final home = stationPos + offset;
      entry.value.position = home;
      entry.value.setHome(home);
    }

    for (final cfg in decorationConfigs) {
      final comp = _decorationComponents[cfg.id];
      if (comp == null) {
        continue;
      }
      comp.position = _decorationAnchor(cfg.id, floorLeft, floorTop, floorW, floorH);
      comp.priority = (cfg.gridY > 1.6 ? RenderLayers.decorationFront : RenderLayers.decorationBack) +
          (comp.position.y / 24).floor();
    }
  }

  Vector2 _stationAnchor(String stationId, double left, double top, double width, double height) {
    final p = switch (stationId) {
      'espresso_machine' => (0.78, 0.24),
      'coffee_grinder' => (0.78, 0.48),
      'pastry_display' => (0.78, 0.72),
      'cashier_counter' => (0.18, 0.38),
      'milk_frother' => (0.52, 0.22),
      'drive_thru_window' => (0.14, 0.26),
      'cold_brew_station' => (0.22, 0.58),
      'dessert_oven' => (0.52, 0.46),
      'roastery_machine' => (0.22, 0.76),
      'vip_lounge' => (0.52, 0.74),
      _ => (0.50, 0.50),
    };
    return Vector2(left + width * p.$1, top + height * p.$2);
  }

  Vector2 _decorationAnchor(String decorationId, double left, double top, double width, double height) {
    final hash = decorationId.codeUnits.fold<int>(0, (sum, char) => sum + char);
    final spots = <(double, double)>[
      (0.10, 0.86),
      (0.90, 0.86),
      (0.10, 0.09),
      (0.90, 0.09),
      (0.36, 0.91),
      (0.64, 0.91),
    ];
    final spot = spots[hash % spots.length];
    return Vector2(left + width * spot.$1, top + height * spot.$2);
  }

  List<Vector2> _updateTablePositions(Rect mapRect) {
    final slots = <String, Vector2>{
      for (final zone in ShopZones.seatingZones) zone.id: zone.resolveSeat(mapRect),
    };
    _tablePositions
      ..clear()
      ..addAll(slots);
    return slots.values.toList(growable: false);
  }

  Vector2 _mapPoint(Rect mapRect, double x, double y) {
    return Vector2(
      mapRect.left + mapRect.width * x,
      mapRect.top + mapRect.height * y,
    );
  }

  Vector2? _deliveryTargetForStation(String stationId) {
    final queue = _controller.currentState.stationQueues[stationId];
    if (queue == null || queue.isEmpty) {
      return null;
    }
    final task = queue.first;
    final orderIndex = _controller.currentState.cafeOrders.indexWhere((item) => item.orderId == task.orderId);
    if (orderIndex < 0) {
      return null;
    }
    final order = _controller.currentState.cafeOrders[orderIndex];
    if (order.tableId == null) {
      return null;
    }
    return _tablePositions[order.tableId!];
  }

  Color _hexColor(String value) {
    final hex = value.replaceAll('#', '');
    final normalized = hex.length == 6 ? 'FF$hex' : hex;
    return Color(int.parse(normalized, radix: 16));
  }

  void _addPopup({
    required Vector2 position,
    required double amount,
    Color color = Colors.amber,
    String? prefix,
  }) {
    if (!_controller.settings.floatingTextEnabled || _activePopups >= _maxPopups) {
      return;
    }
    _activePopups += 1;
    _world?.add(
      CoinPopupComponent(
        position: position,
        amount: amount,
        color: color,
        prefix: prefix,
        onRemoved: () {
          _activePopups = (_activePopups - 1).clamp(0, _maxPopups);
        },
      ),
    );
  }
}

class _CounterReceptionTapZone extends PositionComponent with TapCallbacks {
  _CounterReceptionTapZone({required this.onTap})
      : super(anchor: Anchor.topLeft, priority: RenderLayers.stationBase);

  final void Function(Vector2 worldPosition) onTap;

  void layout(Rect rect) {
    position = Vector2(rect.left, rect.top);
    size = Vector2(rect.width, rect.height);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(event.canvasPosition);
    super.onTapDown(event);
  }
}

// Full-screen white flash added directly to the game (not the world) so it
// renders in screen space on top of everything, then self-removes after 1 s.
class _PrestigeFlashComponent extends PositionComponent {
  _PrestigeFlashComponent({required Vector2 gameSize})
      : super(size: gameSize, priority: 9999);

  double _alpha = 1.0;
  final _paint = Paint();

  @override
  void update(double dt) {
    super.update(dt);
    _alpha = (_alpha - dt).clamp(0.0, 1.0);
    if (_alpha <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _paint.color = Colors.white.withValues(alpha: _alpha);
    canvas.drawRect(size.toRect(), _paint);
  }
}
