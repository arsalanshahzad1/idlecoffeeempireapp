import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/station_config.dart';
import '../models/station_state.dart';
import '../sprites/svg_sprite.dart';
import '../visuals/render_layers.dart';
import '../visuals/sprite_renderer.dart';
import '../visuals/visual_config.dart';
import '../visuals/visual_state_mapper.dart';

class StationComponent extends PositionComponent with TapCallbacks {
  StationComponent({
    required this.config,
    required StationState state,
    required Vector2 position,
    required this.onTap,
    this.showVisuals = true,
  }) : _state = state,
       super(position: position, size: Vector2(92, 60), anchor: Anchor.center, priority: RenderLayers.stationBase);

  final StationConfig config;
  final void Function(String stationId, Vector2 worldPosition) onTap;
  final bool showVisuals;
  StationState _state;
  bool _workerHired = false;
  bool _upgradeAvailable = false;
  int _queueCount = 0;
  SpriteComponent? _sprite;
  SvgComponent? _svgComp;
  bool _lastProducing = false;
  double _producePulse = 0;
  double _badgePulseTime = 0;

  late final RectangleComponent _body;
  late final RectangleComponent _labelBg;
  late final TextComponent _label;
  late final TextComponent _status;
  late final RectangleComponent _progressTrack;
  late final RectangleComponent _progressFill;
  late final CircleComponent _autoDot;
  late final TextComponent _icon;
  late final RectangleComponent _badgeBg;
  late final TextComponent _badgeText;
  late final CircleComponent _produceDot;

  @override
  Future<void> onLoad() async {
    if (!showVisuals) {
      return;
    }
    _body = RectangleComponent(size: size, anchor: Anchor.center, paint: Paint());
    _labelBg = RectangleComponent(
      position: Vector2(0, -size.y * 0.58),
      size: Vector2(size.x * 0.82, 12),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xAA3D1F0D),
    );
    _label = TextComponent(
      text: config.name,
      position: _labelBg.position.clone(),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w900),
      ),
    );
    _status = TextComponent(
      text: '',
      position: Vector2(0, size.y * 0.42),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Color(0xDDFFFFFF), fontSize: 6.5, fontWeight: FontWeight.w700),
      ),
    );
    // Progress track: 8px height for a chunky Eatventure-style bar
    _progressTrack = RectangleComponent(
      size: Vector2(size.x * 0.62, 8),
      position: Vector2(0, size.y * 0.28),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0x553D1F0D),
    );
    _progressFill = RectangleComponent(
      size: Vector2(0, 8),
      position: Vector2(_progressTrack.position.x - (_progressTrack.size.x / 2), _progressTrack.position.y),
      anchor: Anchor.centerLeft,
      paint: Paint()..color = VisualConfig.amber,
    );
    _autoDot = CircleComponent(
      radius: 3.5,
      position: Vector2(size.x * 0.32, -size.y * 0.26),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF757575),
    );
    _badgeBg = RectangleComponent(
      position: Vector2(size.x * 0.40, -size.y * 0.52),
      size: Vector2(28, 14),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFE53935),
    );
    _badgeText = TextComponent(
      text: '',
      position: _badgeBg.position.clone(),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900),
      ),
    );
    _produceDot = CircleComponent(
      radius: 2.5,
      position: Vector2(-size.x * 0.36, -size.y * 0.30),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFFFFB300),
    );
    _icon = TextComponent(
      text: _iconForStation(config.id),
      position: Vector2(0, -2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );

    final visual = VisualStateMapper.station(config.id);
    final sprite = await SpriteRenderer.resolveStationSprite(
      visual,
      unlocked: _state.isUnlocked,
      active: _state.isProducing,
    );
    if (sprite != null) {
      _sprite = SpriteComponent(sprite: sprite, anchor: Anchor.center, size: size);
    }

    final svgAsset = SvgSprites.forStationId(config.id);
    if (svgAsset != null) {
      _svgComp = SvgComponent(
        svg: svgAsset,
        anchor: Anchor.center,
        size: size * 0.82,
        position: Vector2(0, -3),
      );
    }

    addAll([
      _body,
      if (_sprite != null) _sprite!,
      if (_svgComp != null) _svgComp!,
      _icon,
      _labelBg,
      _label,
      _status,
      _progressTrack,
      _progressFill,
      _produceDot,
      _autoDot,
      _badgeBg,
      _badgeText,
    ]);
    applyState(_state);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!showVisuals) return;
    _producePulse = (_producePulse - dt).clamp(0.0, 1.0);
    if (!isLoaded) return;

    _body.size = size;
    _sprite?.size = size;
    if (_svgComp != null) {
      _svgComp!.size = size * 0.82;
      _svgComp!.position = Vector2(0, -3);
    }
    _labelBg.position = Vector2(0, -size.y * 0.58);
    _labelBg.size = Vector2(size.x * 0.82, 12);
    _label.position = _labelBg.position.clone();
    _status.position = Vector2(0, size.y * 0.42);
    _progressTrack.position = Vector2(0, size.y * 0.28);
    _progressTrack.size = Vector2(size.x * 0.62, 8);
    _progressFill.position = Vector2(_progressTrack.position.x - (_progressTrack.size.x / 2), _progressTrack.position.y);
    _progressFill.size.y = _progressTrack.size.y;
    _autoDot.position = Vector2(size.x * 0.32, -size.y * 0.26);
    _badgeBg.position = Vector2(size.x * 0.40, -size.y * 0.52);
    _badgeBg.size = Vector2(28, 14);
    _badgeText.position = _badgeBg.position.clone();
    _produceDot.position = Vector2(-size.x * 0.36, -size.y * 0.30);

    if (_state.isProducing) {
      final pulse = 1 + (0.04 * _producePulse);
      _autoDot.scale = Vector2.all(pulse);
      _produceDot.scale = Vector2.all(1 + (0.25 * _producePulse));
    } else {
      _autoDot.scale = Vector2.all(1);
      _produceDot.scale = Vector2.all(1);
    }

    // Amber pulse on the UP badge when an upgrade is affordable
    if (_upgradeAvailable && _state.isUnlocked) {
      _badgePulseTime += dt;
      final t = math.sin(_badgePulseTime * math.pi * 2 / 0.65) * 0.5 + 0.5;
      _badgeBg.paint.color = Color.lerp(VisualConfig.amber, const Color(0xFFFF6B35), t)!;
    } else {
      _badgePulseTime = 0;
    }
  }

  void applyState(StationState state) {
    if (state.level > _state.level) HapticFeedback.mediumImpact();
    _state = state;
    if (!isLoaded || !showVisuals) return;
    if (state.isProducing && !_lastProducing) {
      _producePulse = 1;
    }
    _lastProducing = state.isProducing;
    _body.paint.color = _colorForStation(state);
    _autoDot.paint.color = state.autoEnabled ? VisualConfig.successGreen : const Color(0xFF757575);
    _produceDot.paint.color = state.isProducing ? const Color(0xFFFFC107) : const Color(0x668D6E63);
    _status.text = _statusText(state);
    final width = _progressTrack.size.x * state.productionProgress.clamp(0.0, 1.0);
    _progressFill.size = Vector2(width, _progressTrack.size.y);
    _progressFill.paint.color = state.blockedReason == null ? VisualConfig.amber : VisualConfig.danger;
    _icon.text = !state.isUnlocked ? 'LCK' : (_svgComp != null ? '' : _iconForStation(config.id));
    _refreshBadge();
    _refreshSpriteForState(state);
  }

  void setWorkerHired(bool workerHired) {
    _workerHired = workerHired;
    if (!isLoaded || !showVisuals) return;
    _status.text = _statusText(_state);
    _refreshBadge();
  }

  void setUpgradeAvailable(bool upgradeAvailable) {
    _upgradeAvailable = upgradeAvailable;
    if (!isLoaded || !showVisuals) return;
    _refreshBadge();
  }

  void setQueueCount(int queueCount) {
    _queueCount = queueCount;
    if (!isLoaded || !showVisuals) return;
    _refreshBadge();
    _status.text = _statusText(_state);
  }

  @override
  void onTapDown(TapDownEvent event) {
    HapticFeedback.lightImpact();
    add(
      ScaleEffect.to(
        Vector2.all(0.94),
        EffectController(duration: 0.06, reverseDuration: 0.11),
      ),
    );
    onTap(config.id, absoluteCenter);
    super.onTapDown(event);
  }

  String _statusText(StationState state) {
    if (!state.isUnlocked) return 'Locked';
    if (state.blockedReason != null) return _shortBlocked(state.blockedReason!);
    if (state.isProducing) return 'Making';
    if (_queueCount > 0) return 'Queue x$_queueCount';
    if (_workerHired && state.autoEnabled) return 'Auto';
    return 'Ready';
  }

  String _shortBlocked(String reason) {
    if (reason.toLowerCase().contains('cups')) return 'No Cups';
    if (reason.toLowerCase().contains('customer')) return 'No Queue';
    return 'Wait';
  }

  Color _colorForStation(StationState state) {
    if (!state.isUnlocked) return VisualConfig.stationLocked;
    final base = switch (config.id) {
      'espresso_machine' => VisualConfig.stationEspresso,
      'coffee_grinder' => VisualConfig.stationGrinder,
      'pastry_display' => VisualConfig.stationPastry,
      _ => VisualConfig.stationDefault,
    };
    if (state.isProducing) return Color.lerp(base, const Color(0xFFFFB74D), 0.28) ?? base;
    if (state.autoEnabled) return Color.lerp(base, VisualConfig.successGreen, 0.2) ?? base;
    return base;
  }

  void _refreshBadge() {
    if (!_state.isUnlocked) {
      _badgeBg.paint.color = VisualConfig.stationLocked;
      _badgeText.text = 'LOCK';
      return;
    }
    if (_upgradeAvailable) {
      // Color is animated by update(); just set the text.
      _badgeBg.paint.color = VisualConfig.amber;
      _badgeText.text = 'UP!';
      return;
    }
    if (_workerHired && _state.autoEnabled) {
      _badgeBg.paint.color = VisualConfig.successGreen;
      _badgeText.text = 'AUTO';
      return;
    }
    if (_state.isProducing) {
      _badgeBg.paint.color = const Color(0xFFFF8F00);
      _badgeText.text = 'RUN';
      return;
    }
    if (_queueCount > 0) {
      _badgeBg.paint.color = const Color(0xFF1976D2);
      _badgeText.text = 'Q$_queueCount';
      return;
    }
    _badgeBg.paint.color = const Color(0x995D4037);
    _badgeText.text = 'OK';
  }

  String _iconForStation(String stationId) {
    return switch (stationId) {
      'espresso_machine' => 'ESP',
      'coffee_grinder' => 'GRD',
      'cashier_counter' => 'POS',
      'milk_frother' => 'MLK',
      'pastry_display' => 'PST',
      'drive_thru_window' => 'DRV',
      'cold_brew_station' => 'CLD',
      'dessert_oven' => 'OVN',
      'roastery_machine' => 'RST',
      'vip_lounge' => 'VIP',
      _ => 'STN',
    };
  }

  Future<void> _refreshSpriteForState(StationState state) async {
    if (!showVisuals) return;
    final visual = VisualStateMapper.station(config.id);
    final sprite = await SpriteRenderer.resolveStationSprite(
      visual,
      unlocked: state.isUnlocked,
      active: state.isProducing,
    );
    if (sprite != null) {
      _sprite?.sprite = sprite;
      _sprite?.size = size;
    }
  }
}
