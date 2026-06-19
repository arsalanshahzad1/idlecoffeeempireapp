import 'dart:ui';

import 'package:flame/components.dart';

import '../visuals/asset_resolver.dart';
import '../visuals/render_layers.dart';
import '../visuals/visual_config.dart';
import 'map_constants.dart';
import 'shop_zones.dart';

class ShopMap extends PositionComponent {
  ShopMap({
    super.priority = RenderLayers.floor,
  }) : super(anchor: Anchor.topLeft);

  Sprite? _mapSprite;
  Rect _mapRect = Rect.zero;
  Color _floorColor = VisualConfig.floorHoney;
  int _evolutionTier = 0;

  Rect get mapRect => _mapRect;
  bool get hasAuthoredMap => _mapSprite != null;

  static const _wallColors = <Color>[
    Color(0xFFFDF4E7), // 0: warm off-white
    Color(0xFFFAEDD8), // 1: warm cream
    Color(0xFFF5E0C0), // 2: light caramel
    Color(0xFFEDD9B4), // 3: warm sandstone
    Color(0xFFD8CFC8), // 4: warm grey marble
    Color(0xFF2E2E2E), // 5: charcoal premium
  ];

  static const _borderColors = <Color>[
    Color(0xFF8B6346), // 0
    Color(0xFF7B5242), // 1
    Color(0xFF6B4232), // 2
    Color(0xFF5C3D2E), // 3
    Color(0xFF7A6560), // 4
    Color(0xFFB8860B), // 5: dark gold
  ];

  void applyFloorColor(Color color) {
    _floorColor = color;
  }

  void applyEvolutionTier(int tier) {
    _evolutionTier = tier.clamp(0, 5);
  }

  @override
  Future<void> onLoad() async {
    _mapSprite = await AssetResolver.tryLoadSprite(MapConstants.starterCafeAsset);
  }

  void layout(Rect rect) {
    _mapRect = rect;
    position = Vector2(rect.left, rect.top);
    size = Vector2(rect.width, rect.height);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) return;
    final sprite = _mapSprite;
    if (sprite == null) {
      _renderFallbackMap(canvas);
      return;
    }
    sprite.render(canvas, position: Vector2.zero(), size: size);
  }

  void _renderFallbackMap(Canvas canvas) {
    final map = Rect.fromLTWH(0, 0, size.x, size.y);
    final wallPaint = Paint()..color = _wallColors[_evolutionTier];
    final borderPaint = Paint()
      ..color = _borderColors[_evolutionTier]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // ── Wall (outer rounded rect) ─────────────────────────────────────────
    canvas.drawRRect(RRect.fromRectAndRadius(map, const Radius.circular(22)), wallPaint);

    // ── Floor (inner area) ────────────────────────────────────────────────
    final floor = map.deflate(map.width * 0.045);
    final floorRRect = RRect.fromRectAndRadius(floor, const Radius.circular(18));
    canvas.drawRRect(floorRRect, Paint()..color = _floorColor);

    // ── Floor plank lines ─────────────────────────────────────────────────
    canvas.save();
    canvas.clipRRect(floorRRect);
    final plankPaint = Paint()
      ..color = VisualConfig.floorPlank.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    var plankY = floor.top + 36.0;
    while (plankY < floor.bottom) {
      canvas.drawLine(Offset(floor.left + 6, plankY), Offset(floor.right - 6, plankY), plankPaint);
      plankY += 38;
    }
    canvas.restore();

    // ── Outer border ──────────────────────────────────────────────────────
    canvas.drawRRect(RRect.fromRectAndRadius(floor, const Radius.circular(18)), borderPaint);

    // ── Tier-gated visual layers ──────────────────────────────────────────
    if (_evolutionTier >= 3) _drawSignage(canvas);
    if (_evolutionTier >= 4) _drawCornerDecorations(canvas);

    // ── Walking paths ─────────────────────────────────────────────────────
    final pathPaint = Paint()
      ..color = VisualConfig.floorPlank.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _drawPaths(canvas, pathPaint);

    // ── Scene elements ────────────────────────────────────────────────────
    for (final zone in ShopZones.stationZones) {
      _drawStation(canvas, zone.resolveRect(map));
    }
    _drawCounter(canvas);
    for (final zone in ShopZones.seatingZones) {
      _drawTable(canvas, Offset(
        zone.normalizedTableCenter.x * map.width,
        zone.normalizedTableCenter.y * map.height,
      ));
    }
    if (_evolutionTier >= 2) _drawSideTables(canvas);
    _drawEntrance(canvas, ShopZones.entranceZone.resolveRect(map));
    _drawQueue(canvas, ShopZones.customerQueueZone.resolveRect(map));
  }

  // ── Tier-gated layers ─────────────────────────────────────────────────────

  void _drawSignage(Canvas canvas) {
    const bgColors = <Color>[
      Color(0x00000000), Color(0x00000000), Color(0x00000000),
      Color(0xFF5C3D2E),
      Color(0xFF37474F),
      Color(0xFF1A1A1A),
    ];
    const textColors = <Color>[
      Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0xFFFFFFFF),
      Color(0xFFFFF8DC),
      Color(0xFFCFD8DC),
      Color(0xFFFFD700),
    ];
    const labels = <String>[
      '', '', '',
      '★ DOWNTOWN',
      '✦ PREMIUM HOUSE',
      '◆ EMPIRE HQ',
    ];

    final bannerH = size.y * 0.045;
    final bannerRect = Rect.fromCenter(
      center: Offset(size.x * 0.50, size.y * 0.04),
      width: size.x * 0.62,
      height: bannerH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bannerRect, const Radius.circular(6)),
      Paint()..color = bgColors[_evolutionTier],
    );
    if (_evolutionTier >= 5) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bannerRect, const Radius.circular(6)),
        Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    _drawText(canvas, labels[_evolutionTier], bannerRect.center, 9, textColors[_evolutionTier]);
  }

  void _drawCornerDecorations(Canvas canvas) {
    final r = (size.x * 0.031).clamp(6.0, 11.0).toDouble();
    final premium = _evolutionTier >= 5;
    _drawPlant(canvas, Offset(size.x * 0.08, size.y * 0.84), r, premium: premium);
    _drawPlant(canvas, Offset(size.x * 0.92, size.y * 0.84), r, premium: premium);
    if (premium) {
      _drawPlant(canvas, Offset(size.x * 0.08, size.y * 0.14), r, premium: true);
      _drawPlant(canvas, Offset(size.x * 0.92, size.y * 0.14), r, premium: true);
    }
  }

  void _drawPlant(Canvas canvas, Offset center, double r, {bool premium = false}) {
    final potColor = premium ? const Color(0xFFB8860B) : VisualConfig.chairWood;
    final leafColor = premium ? const Color(0xFFFFD700) : const Color(0xFF4CAF50);
    final potRect = Rect.fromCenter(
      center: center.translate(0, r * 0.7),
      width: r * 1.4,
      height: r * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(potRect, Radius.circular(r * 0.25)),
      Paint()..color = potColor,
    );
    canvas.drawCircle(center, r, Paint()..color = leafColor);
    if (!premium) {
      canvas.drawCircle(
        center.translate(-r * 0.28, -r * 0.35),
        r * 0.42,
        Paint()..color = const Color(0x5081C784),
      );
    }
  }

  void _drawSideTables(Canvas canvas) {
    final body = Paint()..color = VisualConfig.tableWood.withValues(alpha: 0.85);
    final stroke = Paint()
      ..color = VisualConfig.chairWood
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _drawBarTable(canvas, Offset(size.x * 0.89, size.y * 0.50), body, stroke);
    _drawBarTable(canvas, Offset(size.x * 0.89, size.y * 0.66), body, stroke);
    if (_evolutionTier >= 3) {
      _drawBarTable(canvas, Offset(size.x * 0.11, size.y * 0.50), body, stroke);
      _drawBarTable(canvas, Offset(size.x * 0.11, size.y * 0.66), body, stroke);
    }
  }

  void _drawBarTable(Canvas canvas, Offset center, Paint body, Paint stroke) {
    final r = (size.x * 0.038).clamp(7.0, 13.0).toDouble();
    canvas.drawCircle(center, r, body);
    canvas.drawCircle(center, r, stroke);
    final stool = Paint()..color = VisualConfig.chairWood;
    canvas.drawCircle(center.translate(0, -(r + 4)), 3.5, stool);
    canvas.drawCircle(center.translate(0, r + 4), 3.5, stool);
  }

  // ── Base scene elements ───────────────────────────────────────────────────

  void _drawPaths(Canvas canvas, Paint paint) {
    for (final path in ShopZones.walkingPaths) {
      final points = path.resolve(Rect.fromLTWH(0, 0, size.x, size.y));
      if (points.length < 2) continue;
      final drawPath = Path()..moveTo(points.first.x, points.first.y);
      for (final point in points.skip(1)) {
        drawPath.lineTo(point.x, point.y);
      }
      canvas.drawPath(drawPath, paint);
    }
  }

  void _drawCounter(Canvas canvas) {
    final rect = ShopZones.counterReceptionZone.resolveRect(Rect.fromLTWH(0, 0, size.x, size.y));
    final isPremium = _evolutionTier >= 5;

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(0, 3), const Radius.circular(10)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Counter body
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = isPremium ? const Color(0xFF2D1007) : VisualConfig.counterBrown,
    );
    // Counter top surface
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(8)),
      Paint()..color = isPremium ? const Color(0xFFFFD700) : VisualConfig.counterTop,
    );
    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = isPremium ? const Color(0xFFB8860B) : const Color(0xFF3D1F0D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isPremium ? 2.5 : 2.0,
    );
    _drawText(canvas, 'POS', rect.center, 13, const Color(0xFFFFF3E0));
  }

  void _drawStation(Canvas canvas, Rect rect) {
    final fixture = Rect.fromCenter(
      center: rect.center,
      width: rect.width * 0.78,
      height: rect.height * 0.76,
    );
    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(fixture.translate(0, 3), const Radius.circular(10)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(fixture, const Radius.circular(10)),
      Paint()..color = VisualConfig.counterTop,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(fixture.deflate(5), const Radius.circular(8)),
      Paint()..color = const Color(0xFFFFF8F0),
    );
    final shortestSide = rect.width < rect.height ? rect.width : rect.height;
    canvas.drawCircle(
      fixture.center.translate(0, -fixture.height * 0.08),
      shortestSide * 0.09,
      Paint()..color = VisualConfig.amber,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(fixture, const Radius.circular(10)),
      Paint()
        ..color = VisualConfig.counterBrown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawTable(Canvas canvas, Offset center) {
    final tableR = (size.x * 0.09).clamp(22.0, 32.0).toDouble();
    final chairR = Radius.circular((tableR * 0.22).clamp(4.0, 7.0));
    final chairW = tableR * 0.65;
    final chairH = tableR * 0.38;
    final gap = tableR + chairH * 0.7;
    final chairPaint = Paint()..color = VisualConfig.chairWood;

    // Draw 4 chairs as rounded rectangles before the table (so table overlaps)
    for (final offset in [
      Offset(0, -gap),
      Offset(0, gap),
      Offset(-gap, 0),
      Offset(gap, 0),
    ]) {
      final isHorizontal = offset.dx != 0;
      final cW = isHorizontal ? chairH : chairW;
      final cH = isHorizontal ? chairW : chairH;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center + offset, width: cW, height: cH),
          chairR,
        ),
        chairPaint,
      );
    }

    // Table circle (warm wood)
    canvas.drawCircle(center, tableR, Paint()..color = VisualConfig.tableWood);
    canvas.drawCircle(
      center, tableR,
      Paint()
        ..color = VisualConfig.chairWood
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Subtle grain line
    canvas.drawLine(
      center.translate(-tableR * 0.45, -tableR * 0.25),
      center.translate(tableR * 0.45, tableR * 0.25),
      Paint()
        ..color = VisualConfig.chairWood.withValues(alpha: 0.4)
        ..strokeWidth = 1.5,
    );
  }

  void _drawEntrance(Canvas canvas, Rect rect) {
    // Welcome mat (in front of door)
    final mat = Rect.fromCenter(
      center: rect.center.translate(0, rect.height * 0.5),
      width: rect.width * 0.90,
      height: rect.height * 0.38,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mat, const Radius.circular(6)),
      Paint()..color = VisualConfig.welcomeMat,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mat.deflate(2), const Radius.circular(4)),
      Paint()
        ..color = VisualConfig.floorPlank.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Door panel
    final doorPaint = Paint()..color = const Color(0xFF7BBFB5);
    final strokePaint = Paint()
      ..color = VisualConfig.counterBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final door = Rect.fromCenter(
      center: rect.center,
      width: rect.width * 0.58,
      height: rect.height * 0.56,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(door, const Radius.circular(8)), doorPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(door, const Radius.circular(8)), strokePaint);
    _drawText(canvas, 'ENTRANCE', door.center, 7.5, const Color(0xFF004D40));
  }

  void _drawQueue(Canvas canvas, Rect rect) {
    // Light background area
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()..color = const Color(0xFFF0E0D0).withValues(alpha: 0.55),
    );
    // Border
    final borderPaint = Paint()
      ..color = VisualConfig.counterTop
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      borderPaint,
    );

    final slotBgPaint = Paint()..color = const Color(0xFFFFF8F0).withValues(alpha: 0.85);
    final dotPaint = Paint()..color = VisualConfig.floorHoney.withValues(alpha: 0.7);

    for (var i = 0; i < 5; i++) {
      final center = Offset(rect.left + rect.width * (0.18 + i * 0.16), rect.center.dy);

      // Connecting dots between slots
      if (i < 4) {
        final nextCenter = Offset(rect.left + rect.width * (0.18 + (i + 1) * 0.16), rect.center.dy);
        for (var d = 1; d <= 3; d++) {
          final dotX = center.dx + (nextCenter.dx - center.dx) * d / 4;
          canvas.drawCircle(Offset(dotX, center.dy), 2, dotPaint);
        }
      }
      // Slot circle
      canvas.drawCircle(center, 9, slotBgPaint);
      canvas.drawCircle(center, 9, borderPaint);
      _drawText(canvas, '${i + 1}', center, 7.5, VisualConfig.counterTop);
    }
  }

  void _drawText(Canvas canvas, String text, Offset center, double fontSize, Color color) {
    final builder = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center))
      ..pushStyle(TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w700))
      ..addText(text);
    final paragraph = builder.build()..layout(ParagraphConstraints(width: size.x));
    canvas.drawParagraph(
      paragraph,
      Offset(center.dx - paragraph.maxIntrinsicWidth / 2, center.dy - paragraph.height / 2),
    );
  }
}
