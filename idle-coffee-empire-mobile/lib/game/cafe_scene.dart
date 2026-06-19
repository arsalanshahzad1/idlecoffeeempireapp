import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../visuals/render_layers.dart';
import 'shop_map.dart';

class CafeScene extends Component {
  CafeScene({required this.world, super.priority = RenderLayers.floor});

  final World world;
  late final ShopMap _shopMap;
  Rect _currentMapRect = Rect.zero;

  Rect get mapRect => _currentMapRect;
  bool get usesFallbackMap => !_shopMap.hasAuthoredMap;

  @override
  Future<void> onLoad() async {
    _shopMap = ShopMap(priority: priority);
    await world.add(_shopMap);
    _shopMap.layout(_currentMapRect);
  }

  void updateMapRect(Rect rect) {
    _currentMapRect = rect;
    if (isLoaded) {
      _shopMap.layout(rect);
    }
  }

  void updateFloorPoints(List<Vector2> points) {
    if (points.length < 3) {
      return;
    }
    final xs = points.map((point) => point.x);
    final ys = points.map((point) => point.y);
    updateMapRect(
      Rect.fromLTRB(
        xs.reduce((a, b) => a < b ? a : b),
        ys.reduce((a, b) => a < b ? a : b),
        xs.reduce((a, b) => a > b ? a : b),
        ys.reduce((a, b) => a > b ? a : b),
      ),
    );
  }

  void setFloorColor(Color color) {
    if (isLoaded) _shopMap.applyFloorColor(color);
  }

  void setEvolutionTier(int tier) {
    if (isLoaded) _shopMap.applyEvolutionTier(tier);
  }
}
