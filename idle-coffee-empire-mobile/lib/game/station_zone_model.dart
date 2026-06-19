import 'dart:ui';

import 'package:flame/components.dart';

class StationZoneModel {
  StationZoneModel({
    required this.id,
    required this.normalizedRect,
    required this.interactionAnchor,
    this.stationId,
    this.pathAnchor,
    this.deliveryAnchor,
    this.upgradeSlotId,
  });

  final String id;
  final String? stationId;
  final Rect normalizedRect;
  final Vector2 interactionAnchor;
  final Vector2? pathAnchor;
  final Vector2? deliveryAnchor;
  final String? upgradeSlotId;

  bool containsNormalized(Vector2 point) {
    return normalizedRect.contains(Offset(point.x, point.y));
  }

  Vector2 resolveInteractionPoint(Rect mapRect) => _resolve(mapRect, interactionAnchor);

  Vector2 resolvePathPoint(Rect mapRect) => _resolve(mapRect, pathAnchor ?? interactionAnchor);

  Vector2 resolveDeliveryPoint(Rect mapRect) => _resolve(mapRect, deliveryAnchor ?? pathAnchor ?? interactionAnchor);

  Rect resolveRect(Rect mapRect) {
    return Rect.fromLTWH(
      mapRect.left + normalizedRect.left * mapRect.width,
      mapRect.top + normalizedRect.top * mapRect.height,
      normalizedRect.width * mapRect.width,
      normalizedRect.height * mapRect.height,
    );
  }

  Vector2 _resolve(Rect mapRect, Vector2 normalizedPoint) {
    return Vector2(
      mapRect.left + normalizedPoint.x * mapRect.width,
      mapRect.top + normalizedPoint.y * mapRect.height,
    );
  }
}

class SeatingZoneModel {
  SeatingZoneModel({
    required this.id,
    required this.normalizedTableCenter,
    required this.normalizedSeat,
    required this.capacity,
  });

  final String id;
  final Vector2 normalizedTableCenter;
  final Vector2 normalizedSeat;
  final int capacity;

  Vector2 resolveSeat(Rect mapRect) {
    return Vector2(
      mapRect.left + normalizedSeat.x * mapRect.width,
      mapRect.top + normalizedSeat.y * mapRect.height,
    );
  }
}

class WalkingPathModel {
  WalkingPathModel({
    required this.id,
    required this.normalizedPoints,
  });

  final String id;
  final List<Vector2> normalizedPoints;

  List<Vector2> resolve(Rect mapRect) {
    return normalizedPoints
        .map(
          (point) => Vector2(
            mapRect.left + point.x * mapRect.width,
            mapRect.top + point.y * mapRect.height,
          ),
        )
        .toList(growable: false);
  }
}
