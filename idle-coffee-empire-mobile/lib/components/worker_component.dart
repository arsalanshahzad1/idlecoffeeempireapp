import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

import '../sprites/svg_sprite.dart';
import '../visuals/render_layers.dart';
import '../visuals/sprite_renderer.dart';
import '../visuals/visual_state_mapper.dart';

class WorkerComponent extends PositionComponent {
  WorkerComponent({
    required this.workerId,
    required this.stationId,
    required Vector2 position,
    this.assetPath,
  }) : super(position: position, size: Vector2(18, 24), anchor: Anchor.center, priority: RenderLayers.worker);

  final String workerId;
  final String stationId;
  final String? assetPath;
  bool _isWorking = false;
  double _time = 0;
  Vector2? _homePosition;
  Vector2? _targetPosition;
  // SVG sprite (highest priority renderer)
  Svg? _svg;
  // PNG sprite fallback
  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    // SVG resolved from the preloaded SvgSprites registry
    _svg = SvgSprites.forWorkerId(workerId);

    // PNG sprite fallback (assets/images/ paths)
    final mapped = VisualStateMapper.worker(workerId);
    _sprite = await SpriteRenderer.loadFirstAvailable(<String>[mapped.idle, mapped.active ?? '']);
  }

  void setWorking(bool value) {
    _isWorking = value;
  }

  void setHome(Vector2 value) {
    _homePosition = value.clone();
    _targetPosition ??= _homePosition!.clone();
  }

  void deliverTo(Vector2? target) {
    _targetPosition = target?.clone() ?? _homePosition?.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    final target = _targetPosition;
    if (target != null) {
      final delta = target - position;
      final distance = delta.length;
      if (distance > 1) {
        final step = (64 * dt).clamp(0.0, distance).toDouble();
        position += delta.normalized() * step;
      }
    }
    final bob = math.sin(_time * (_isWorking ? 9.0 : 4.0)) * (_isWorking ? 1.6 : 0.8);
    y += bob * dt * 6;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ── 1. SVG body (highest priority) ─────────────────────────────────────
    final svg = _svg;
    if (svg != null) {
      canvas.save();
      canvas.translate(-size.x / 2, -size.y / 2);
      svg.render(canvas, size.clone());
      canvas.restore();
      if (_isWorking) {
        canvas.drawCircle(
          Offset(size.x * 0.45, -size.y * 0.2),
          2,
          Paint()..color = const Color(0xFF66BB6A),
        );
        _drawTray(canvas);
      }
      return;
    }

    // ── 2. PNG sprite fallback ──────────────────────────────────────────────
    if (_sprite != null) {
      _sprite!.render(
        canvas,
        position: Vector2(-size.x / 2, -size.y / 2),
        size: size,
      );
      if (_isWorking) {
        canvas.drawCircle(Offset(size.x * 0.45, -size.y * 0.2), 2, Paint()..color = const Color(0xFF66BB6A));
        _drawTray(canvas);
      }
      return;
    }

    // ── 3. Shape fallback ───────────────────────────────────────────────────
    final color = _colorForWorker(workerId);
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, Paint()..color = color);
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF2E1A16)..style = PaintingStyle.stroke);

    canvas.drawRect(
      Rect.fromCenter(center: Offset(0, -size.y * 0.26), width: size.x * 0.9, height: 4),
      Paint()..color = const Color(0xFF004D40),
    );

    final badge = stationId.split('_').first.substring(0, 1).toUpperCase();
    final tp = TextPainter(
      text: TextSpan(text: badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, size.y * 0.05));

    if (_isWorking) {
      canvas.drawCircle(Offset(size.x * 0.5, -size.y * 0.25), 2, Paint()..color = const Color(0xFF66BB6A));
      _drawTray(canvas);
    }
  }

  void _drawTray(Canvas canvas) {
    final trayRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x * 0.45, size.y * 0.1), width: 18, height: 9),
      const Radius.circular(5),
    );
    canvas.drawRRect(trayRect, Paint()..color = const Color(0xFFFDF8EE));
    canvas.drawRRect(
      trayRect,
      Paint()
        ..color = const Color(0xFF4E342E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final label = switch (stationId) {
      'espresso_machine' => 'ESP',
      'coffee_grinder'   => 'GRD',
      'pastry_display'   => 'CAKE',
      _ => '.',
    };
    final tp = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x * 0.45 - tp.width / 2, size.y * 0.1 - tp.height / 2));
  }
}

Color _colorForWorker(String workerId) {
  return switch (workerId) {
    'barista_worker'        => const Color(0xFF00ACC1),
    'burger_cook'           => const Color(0xFF7E57C2),
    'cashier_worker'        => const Color(0xFF7E57C2),
    'frother_assistant'     => const Color(0xFF42A5F5),
    'pastry_chef'           => const Color(0xFFFF7043),
    'drive_thru_attendant'  => const Color(0xFF26A69A),
    'cold_brew_specialist'  => const Color(0xFF5C6BC0),
    'dessert_baker'         => const Color(0xFFD81B60),
    'roastery_operator'     => const Color(0xFF6D4C41),
    'vip_host'              => const Color(0xFFFFD54F),
    _ => const Color(0xFF00ACC1),
  };
}
