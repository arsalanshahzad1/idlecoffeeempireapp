import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../models/decoration_config.dart';
import '../visuals/asset_registry.dart';
import '../visuals/render_layers.dart';
import '../visuals/sprite_renderer.dart';

class DecorationComponent extends PositionComponent {
  DecorationComponent({
    required this.config,
    required Vector2 position,
    required bool purchased,
  }) : _purchased = purchased,
       super(position: position, size: Vector2(22, 22), anchor: Anchor.center, priority: RenderLayers.decorationBack);

  final DecorationConfig config;
  bool _purchased;
  SpriteComponent? _sprite;

  @override
  Future<void> onLoad() async {
    final sprite = await SpriteRenderer.loadFirstAvailable(<String>[
      config.assetPath ?? '',
      '${AssetRegistry.decorationsRoot}/${config.id}.png',
    ]);
    if (sprite != null) {
      _sprite = SpriteComponent(sprite: sprite, size: size, anchor: Anchor.center);
      add(_sprite!);
    }
  }

  void setPurchased(bool purchased) {
    _purchased = purchased;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!_purchased || _sprite != null) return;
    final base = Color(config.colorHex);
    final shadow = Paint()..color = const Color(0x332E1A16);
    final body = Paint()..color = base;
    final stroke = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 8), width: 18, height: 6), shadow);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 18, height: 18),
      const Radius.circular(5),
    );
    canvas.drawRRect(rect, body);
    canvas.drawRRect(rect, stroke);
  }
}
