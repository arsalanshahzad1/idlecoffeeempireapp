import 'package:flame/effects.dart';
import 'package:flame/components.dart';

class EffectHelpers {
  EffectHelpers._();

  static Effect bounce({double up = 6, double inMs = 90, double outMs = 120}) {
    return MoveEffect.by(
      Vector2(0, -up),
      EffectController(duration: inMs / 1000, reverseDuration: outMs / 1000),
    );
  }

  static Effect pulse({double to = 1.08, double durationMs = 220}) {
    return ScaleEffect.to(
      Vector2.all(to),
      EffectController(duration: durationMs / 1000, reverseDuration: durationMs / 1000),
    );
  }

  static Effect drift(Vector2 by, {double durationMs = 500}) {
    return MoveEffect.by(by, EffectController(duration: durationMs / 1000));
  }
}
