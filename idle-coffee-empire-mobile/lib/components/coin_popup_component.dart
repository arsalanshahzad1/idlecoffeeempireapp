import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../visuals/render_layers.dart';

class CoinPopupComponent extends TextComponent {
  static int _laneIndex = 0;

  CoinPopupComponent({
    required Vector2 position,
    required double amount,
    Color color = Colors.amber,
    String? prefix,
    this.onRemoved,
  }) : super(
         text: '${prefix ?? '+'}${amount.toStringAsFixed(0)}',
         position: position,
         anchor: Anchor.center,
         textRenderer: TextPaint(
           style: TextStyle(
             color: color,
             fontSize: 14,
             fontWeight: FontWeight.bold,
           ),
         ),
       ) {
    priority = RenderLayers.floatingText;
    final lane = (_laneIndex++ % 4) - 1.5;
    position += Vector2(lane * 10, -lane.abs() * 2);
    final rise = amount >= 1000 ? -30.0 : -24.0;
    final life = amount >= 1000 ? 0.8 : 0.65;
    add(MoveEffect.by(Vector2(lane * 5, rise), EffectController(duration: life)));
    add(
      ScaleEffect.to(
        Vector2.all(amount >= 1000 ? 1.22 : 1.15),
        EffectController(duration: 0.16, reverseDuration: 0.42),
      ),
    );
    add(
      TimerComponent(
        period: life,
        removeOnFinish: true,
        onTick: removeFromParent,
      ),
    );
  }

  final VoidCallback? onRemoved;

  @override
  void onRemove() {
    onRemoved?.call();
    super.onRemove();
  }
}
