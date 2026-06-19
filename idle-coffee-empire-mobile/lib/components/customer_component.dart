import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../sprites/svg_sprite.dart';
import '../visuals/render_layers.dart';
import '../visuals/sprite_renderer.dart';
import '../visuals/visual_state_mapper.dart';

enum CustomerPhase { enteringQueue, waitingQueue, walkingToTable, seated, leaving }
enum CustomerVisualState { idle, moving, waiting, serving }

class CustomerComponent extends PositionComponent {
  CustomerComponent({
    required Vector2 position,
    required this.moveSpeed,
    required this.customerTypeId,
    required Color color,
    required double radius,
    this.assetPath,
  }) : _baseColor = color,
       _radius = radius,
       super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center, priority: RenderLayers.customer);

  final double moveSpeed;
  final String customerTypeId;
  final String? assetPath;
  final Color _baseColor;
  final double _radius;

  CustomerPhase phase = CustomerPhase.enteringQueue;
  Vector2 _target = Vector2.zero();
  double _time = 0;
  double _servedPulse = 0;
  double _arrivalPulse = 0;
  // SVG sprite (highest priority renderer)
  Svg? _svg;
  // PNG sprite (fallback if no SVG)
  Sprite? _sprite;
  CustomerVisualState _visualState = CustomerVisualState.moving;
  List<String> _orderIcons = const <String>[];
  int _deliveredItems = 0;
  int _totalItems = 0;
  double _patienceRatio = 1;

  bool _leftHappy = false;
  double _exitTintTimer = 0;
  double _exitEmojiTimer = 0;
  double _shakeTimer = 0;
  double _patienceFlashTimer = 0;

  @override
  Future<void> onLoad() async {
    // SVG — resolved from the preloaded SvgSprites registry
    _svg = SvgSprites.forCustomerType(customerTypeId);

    // PNG sprite fallback (still tries assets/images/ paths)
    final mapped = VisualStateMapper.customer(customerTypeId);
    _sprite = await SpriteRenderer.loadFirstAvailable(
      <String>[mapped.idle, mapped.active ?? '', mapped.locked ?? ''],
    );
  }

  void moveTo(Vector2 target, {CustomerPhase? phase}) {
    _target = target;
    if (phase != null) {
      if (phase == CustomerPhase.leaving && this.phase != CustomerPhase.leaving) {
        _triggerExitEffects();
      }
      this.phase = phase;
    }
  }

  void triggerServedFeedback() {
    HapticFeedback.lightImpact();
    _servedPulse = 0.35;
    _visualState = CustomerVisualState.serving;
    _leftHappy = true;
  }

  void triggerArrivalFeedback() {
    _arrivalPulse = 0.28;
  }

  void setOrderBubble({
    required List<String> icons,
    required int deliveredItems,
    required int totalItems,
    required double patienceRatio,
  }) {
    _orderIcons = icons;
    _deliveredItems = deliveredItems;
    _totalItems = totalItems;
    _patienceRatio = patienceRatio.clamp(0.0, 1.0).toDouble();
  }

  void _triggerExitEffects() {
    _exitTintTimer = 0.3;
    _exitEmojiTimer = 0.5;
    if (!_leftHappy) {
      HapticFeedback.mediumImpact();
      _shakeTimer = 0.3;
      _patienceFlashTimer = 0.3;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    _servedPulse = (_servedPulse - dt).clamp(0.0, 0.35);
    _arrivalPulse = (_arrivalPulse - dt).clamp(0.0, 0.28);
    _exitTintTimer = (_exitTintTimer - dt).clamp(0.0, 0.3);
    _exitEmojiTimer = (_exitEmojiTimer - dt).clamp(0.0, 0.5);
    _shakeTimer = (_shakeTimer - dt).clamp(0.0, 0.3);
    _patienceFlashTimer = (_patienceFlashTimer - dt).clamp(0.0, 0.3);

    final delta = _target - position;
    final distance = delta.length;
    if (distance > 0.5) {
      _visualState = CustomerVisualState.moving;
      final eased = phase == CustomerPhase.leaving ? 1.18 : 1.0;
      final step = (moveSpeed * dt * eased).clamp(0.0, distance).toDouble();
      position += delta.normalized() * step;
    } else {
      position = _target;
      if (phase != CustomerPhase.waitingQueue) {
        _visualState = CustomerVisualState.idle;
      }
    }

    if (phase == CustomerPhase.waitingQueue || phase == CustomerPhase.seated) {
      _visualState = CustomerVisualState.waiting;
      final bob = math.sin(_time * 4.4) * 0.9;
      y += bob * dt * 8;
    }
    priority = RenderLayers.customer + (position.y / 20).floor();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final shakeOffset = _shakeTimer > 0
        ? 4.0 * math.sin((0.3 - _shakeTimer) * math.pi * 20)
        : 0.0;
    if (shakeOffset != 0.0) {
      canvas.save();
      canvas.translate(shakeOffset, 0);
    }

    final servedBoost = _servedPulse > 0 ? (_servedPulse / 0.35) * 0.18 : 0.0;
    final arrivalBoost = _arrivalPulse > 0 ? (_arrivalPulse / 0.28) * 0.12 : 0.0;
    final pulseBoost = servedBoost + arrivalBoost;
    final scale = 1.0 + pulseBoost;
    final radius = _radius * scale;

    final exitFactor = _exitTintTimer > 0 ? (_exitTintTimer / 0.3) : 0.0;
    final exitColor = _leftHappy ? const Color(0xFF4CAF50) : const Color(0xFFE53935);

    // ── 1. SVG body (highest priority) ─────────────────────────────────────
    final svg = _svg;
    if (svg != null) {
      canvas.save();
      canvas.translate(-radius, -radius);
      svg.render(canvas, Vector2(radius * 2, radius * 2));
      canvas.restore();

      // Happy/unhappy exit tint overlay
      if (exitFactor > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 2),
            Radius.circular(radius * 0.3),
          ),
          Paint()
            ..color = exitColor.withValues(alpha: exitFactor * 0.4),
        );
      }
      _drawOrderBubble(canvas, radius);
      _drawExitEmoji(canvas, radius);
      if (shakeOffset != 0.0) canvas.restore();
      return;
    }

    // ── 2. PNG sprite fallback ──────────────────────────────────────────────
    final bodyColor = Color.lerp(_baseColor, Colors.white, pulseBoost) ?? _baseColor;
    final tintedBodyColor = exitFactor > 0
        ? (Color.lerp(bodyColor, exitColor, exitFactor * 0.45) ?? bodyColor)
        : bodyColor;

    if (_sprite != null) {
      _sprite!.render(
        canvas,
        position: Vector2(-radius, -radius),
        size: Vector2.all(radius * 2),
      );
      if (exitFactor > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 2),
            Radius.circular(radius * 0.3),
          ),
          Paint()
            ..color = Color.fromARGB(
              (exitFactor * 0.4 * 255).round(),
              (exitColor.r * 255.0).round().clamp(0, 255),
              (exitColor.g * 255.0).round().clamp(0, 255),
              (exitColor.b * 255.0).round().clamp(0, 255),
            ),
        );
      }
      _drawOrderBubble(canvas, radius);
      _drawExitEmoji(canvas, radius);
      if (shakeOffset != 0.0) canvas.restore();
      return;
    }

    // ── 3. Shape fallback ───────────────────────────────────────────────────
    final tint = switch (_visualState) {
      CustomerVisualState.waiting => Colors.white,
      CustomerVisualState.serving => const Color(0xFFFFF59D),
      _ => tintedBodyColor,
    };
    final bodyPaint = Paint()..color = Color.lerp(tintedBodyColor, tint, 0.1) ?? tintedBodyColor;
    final outline = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: radius * 1.7, height: radius * 2),
      Radius.circular(radius * 0.5),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, outline);

    final headPaint = Paint()..color = Color.lerp(tintedBodyColor, Colors.white, 0.15) ?? tintedBodyColor;
    canvas.drawCircle(Offset(0, -radius * 0.72), radius * 0.5, headPaint);
    canvas.drawCircle(Offset(0, -radius * 0.72), radius * 0.5, outline);

    if (customerTypeId == 'vip_guest') {
      canvas.drawCircle(Offset(0, -radius * 1.3), radius * 0.16, Paint()..color = const Color(0xFFFFD54F));
    } else if (customerTypeId == 'influencer') {
      canvas.drawRect(Rect.fromCenter(center: Offset(radius * 0.15, -radius * 0.65), width: radius * 0.65, height: 2), Paint()..color = const Color(0xFFEC407A));
    } else if (customerTypeId == 'student') {
      canvas.drawRect(Rect.fromCenter(center: Offset(-radius * 0.45, -radius * 0.5), width: radius * 0.26, height: radius * 0.75), Paint()..color = const Color(0xFF3949AB));
    }

    _drawOrderBubble(canvas, radius);
    _drawExitEmoji(canvas, radius);

    if (shakeOffset != 0.0) canvas.restore();
  }

  void _drawExitEmoji(Canvas canvas, double radius) {
    if (_exitEmojiTimer <= 0) return;
    final progress = 1.0 - (_exitEmojiTimer / 0.5);
    final yOffset = -radius * 3.2 - progress * radius * 0.8;

    // Use emotion SVG when available
    final emotionSvg = SvgSprites.forExitMood(happy: _leftHappy);
    if (emotionSvg != null) {
      const emojiSize = 20.0;
      canvas.save();
      canvas.translate(-emojiSize / 2, yOffset - emojiSize / 2);
      emotionSvg.render(canvas, Vector2.all(emojiSize));
      canvas.restore();
      return;
    }

    // Emoji text fallback
    final tp = TextPainter(
      text: TextSpan(
        text: _leftHappy ? '😊' : '😠',
        style: const TextStyle(fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, yOffset - tp.height / 2));
  }

  void _drawOrderBubble(Canvas canvas, double radius) {
    if (_totalItems <= 0 || _orderIcons.isEmpty) return;
    if (phase == CustomerPhase.leaving && _patienceFlashTimer <= 0) return;
    final singleItemOrder = _orderIcons.every((icon) => icon == _orderIcons.first);
    final bubbleW = singleItemOrder ? 58.0 : math.max(42.0, 24.0 + _orderIcons.length * 18.0);
    const bubbleH = 26.0;
    final top = -radius * 2.9;
    final rect = Rect.fromCenter(center: Offset(0, top), width: bubbleW, height: bubbleH);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(9));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFDF8EE));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Draw patience-warning SVG icon in top-left corner when patience is low
    if (_patienceRatio < 0.35 && SvgSprites.patienceWarning != null) {
      canvas.save();
      canvas.translate(rect.left + 2, rect.top + 2);
      SvgSprites.patienceWarning!.render(canvas, Vector2.all(10));
      canvas.restore();
    }

    if (singleItemOrder) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${_orderIcons.first} x$_totalItems',
          style: const TextStyle(color: Color(0xFF4E342E), fontSize: 13, fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: bubbleW - 8);
      tp.paint(canvas, Offset(rect.left + (rect.width - tp.width) / 2, rect.top + 3));
    } else {
      for (var i = 0; i < _orderIcons.length; i++) {
        final tp = TextPainter(
          text: TextSpan(
            text: _orderIcons[i],
            style: const TextStyle(color: Color(0xFF4E342E), fontSize: 7, fontWeight: FontWeight.w900),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 17);
        tp.paint(canvas, Offset(rect.left + 6 + i * 18, rect.top + 4));
      }
    }

    final progress = '$_deliveredItems/$_totalItems';
    final progressPainter = TextPainter(
      text: TextSpan(
        text: progress,
        style: TextStyle(
          color: _deliveredItems >= _totalItems ? const Color(0xFF2E7D32) : const Color(0xFF3E2723),
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    progressPainter.paint(canvas, Offset(rect.right - progressPainter.width - 5, rect.bottom - 12));

    final patienceBarColor = _patienceFlashTimer > 0
        ? const Color(0xFFE53935)
        : (_patienceRatio < 0.28 ? const Color(0xFFE53935) : const Color(0xFF66BB6A));
    final barRect = Rect.fromLTWH(rect.left + 5, rect.bottom - 5, (rect.width - 10) * _patienceRatio, 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
      Paint()..color = patienceBarColor,
    );
  }
}
