import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class AssetResolver {
  AssetResolver._();

  static final Set<String> _knownAssets = <String>{};
  static final Map<String, Sprite?> _spriteCache = <String, Sprite?>{};
  static bool _loadedManifest = false;

  static Future<bool> hasAsset(String? assetPath) async {
    if (assetPath == null || assetPath.isEmpty) return false;
    await _ensureManifestLoaded();
    return _knownAssets.contains(assetPath);
  }

  static Future<Sprite?> tryLoadSprite(String? assetPath) async {
    if (!await hasAsset(assetPath)) return null;
    final cached = _spriteCache[assetPath];
    if (cached != null) {
      return cached;
    }
    try {
      final sprite = await Sprite.load(assetPath!);
      _spriteCache[assetPath] = sprite;
      return sprite;
    } catch (_) {
      _spriteCache[assetPath!] = null;
      return null;
    }
  }

  static Future<void> _ensureManifestLoaded() async {
    if (_loadedManifest) return;
    _loadedManifest = true;
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final decoded = json.decode(manifest);
      if (decoded is Map<String, dynamic>) {
        _knownAssets.addAll(decoded.keys);
      }
    } catch (_) {
      // Keep placeholder fallback active.
    }
  }
}
