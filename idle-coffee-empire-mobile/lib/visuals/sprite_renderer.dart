import 'package:flame/components.dart';

import 'asset_resolver.dart';

class SpriteVisualState {
  const SpriteVisualState({
    required this.idle,
    this.active,
    this.locked,
    this.frames = const <String>[],
  });

  final String idle;
  final String? active;
  final String? locked;
  final List<String> frames;
}

class SpriteRenderer {
  SpriteRenderer._();

  static Future<Sprite?> loadFirstAvailable(List<String> candidates) async {
    for (final path in candidates) {
      final sprite = await AssetResolver.tryLoadSprite(path);
      if (sprite != null) {
        return sprite;
      }
    }
    return null;
  }

  static Future<Sprite?> resolveStationSprite(
    SpriteVisualState state, {
    required bool unlocked,
    required bool active,
  }) async {
    final candidates = <String>[];
    if (!unlocked && state.locked != null) {
      candidates.add(state.locked!);
    }
    if (active && state.active != null) {
      candidates.add(state.active!);
    }
    candidates.add(state.idle);
    if (state.active != null) {
      candidates.add(state.active!);
    }
    return loadFirstAvailable(candidates);
  }

  static Future<List<Sprite>> resolveAnimationFrames(List<String> framePaths) async {
    final result = <Sprite>[];
    for (final path in framePaths) {
      final sprite = await AssetResolver.tryLoadSprite(path);
      if (sprite != null) {
        result.add(sprite);
      }
    }
    return result;
  }
}
