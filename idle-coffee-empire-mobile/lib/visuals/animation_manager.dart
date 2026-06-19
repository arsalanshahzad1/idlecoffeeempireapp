import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class AnimationManager {
  const AnimationManager();

  void applyIdleLoop(PositionComponent target, {double amplitude = 1.0}) {
    target.add(
      MoveEffect.by(
        Vector2(0, -amplitude),
        EffectController(duration: 0.7, reverseDuration: 0.7, infinite: true),
      ),
    );
  }

  void applyPulse(PositionComponent target, {double scale = 1.05}) {
    target.add(
      ScaleEffect.to(
        Vector2.all(scale),
        EffectController(duration: 0.16, reverseDuration: 0.22),
      ),
    );
  }

  void applyMovement(PositionComponent target, Vector2 by, {double durationSeconds = 0.2}) {
    target.add(MoveEffect.by(by, EffectController(duration: durationSeconds)));
  }
}
