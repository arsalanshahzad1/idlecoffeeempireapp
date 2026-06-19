// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flame/components.dart';

import 'station_zone_model.dart';

// Flame's Vector2 is mutable and not const-constructible in the supported
// engine version, so these normalized map zones intentionally stay runtime
// singletons instead of const objects.
class ShopZones {
  ShopZones._();

  static final entranceZone = StationZoneModel(
    id: 'entrance',
    normalizedRect: Rect.fromLTWH(0.40, 0.90, 0.20, 0.07),
    interactionAnchor: Vector2(0.50, 0.93),
    pathAnchor: Vector2(0.50, 0.86),
  );

  static final customerQueueZone = StationZoneModel(
    id: 'customer_queue',
    normalizedRect: Rect.fromLTWH(0.18, 0.32, 0.64, 0.07),
    interactionAnchor: Vector2(0.50, 0.35),
    pathAnchor: Vector2(0.50, 0.35),
  );

  static final counterReceptionZone = StationZoneModel(
    id: 'counter_reception',
    normalizedRect: Rect.fromLTWH(0.10, 0.22, 0.80, 0.08),
    interactionAnchor: Vector2(0.50, 0.26),
    pathAnchor: Vector2(0.50, 0.33),
    deliveryAnchor: Vector2(0.50, 0.30),
    upgradeSlotId: 'cashier_counter',
  );

  static final stationZones = <StationZoneModel>[
    StationZoneModel(
      id: 'coffee_station',
      stationId: 'espresso_machine',
      normalizedRect: Rect.fromLTWH(0.12, 0.09, 0.20, 0.10),
      interactionAnchor: Vector2(0.22, 0.14),
      pathAnchor: Vector2(0.28, 0.20),
      deliveryAnchor: Vector2(0.28, 0.20),
      upgradeSlotId: 'coffee_station_upgrade',
    ),
    StationZoneModel(
      id: 'bakery_station',
      stationId: 'pastry_display',
      normalizedRect: Rect.fromLTWH(0.40, 0.09, 0.20, 0.10),
      interactionAnchor: Vector2(0.50, 0.14),
      pathAnchor: Vector2(0.50, 0.20),
      deliveryAnchor: Vector2(0.50, 0.20),
      upgradeSlotId: 'bakery_station_upgrade',
    ),
    StationZoneModel(
      id: 'burger_grill_station',
      stationId: 'coffee_grinder',
      normalizedRect: Rect.fromLTWH(0.68, 0.09, 0.20, 0.10),
      interactionAnchor: Vector2(0.78, 0.14),
      pathAnchor: Vector2(0.72, 0.20),
      deliveryAnchor: Vector2(0.72, 0.20),
      upgradeSlotId: 'grill_station_upgrade',
    ),
  ];

  static final allInteractiveZones = <StationZoneModel>[
    counterReceptionZone,
    ...stationZones,
  ];

  static final seatingZones = <SeatingZoneModel>[
    SeatingZoneModel(
      id: 'table_1',
      normalizedTableCenter: Vector2(0.23, 0.53),
      normalizedSeat: Vector2(0.23, 0.50),
      capacity: 4,
    ),
    SeatingZoneModel(
      id: 'table_2',
      normalizedTableCenter: Vector2(0.50, 0.53),
      normalizedSeat: Vector2(0.50, 0.50),
      capacity: 4,
    ),
    SeatingZoneModel(
      id: 'table_3',
      normalizedTableCenter: Vector2(0.77, 0.53),
      normalizedSeat: Vector2(0.77, 0.50),
      capacity: 4,
    ),
    SeatingZoneModel(
      id: 'table_4',
      normalizedTableCenter: Vector2(0.23, 0.73),
      normalizedSeat: Vector2(0.23, 0.70),
      capacity: 4,
    ),
    SeatingZoneModel(
      id: 'table_5',
      normalizedTableCenter: Vector2(0.50, 0.73),
      normalizedSeat: Vector2(0.50, 0.70),
      capacity: 4,
    ),
    SeatingZoneModel(
      id: 'table_6',
      normalizedTableCenter: Vector2(0.77, 0.73),
      normalizedSeat: Vector2(0.77, 0.70),
      capacity: 4,
    ),
  ];

  static final walkingPaths = <WalkingPathModel>[
    WalkingPathModel(
      id: 'entrance_to_queue',
      normalizedPoints: <Vector2>[
        Vector2(0.50, 0.88),
        Vector2(0.50, 0.72),
        Vector2(0.50, 0.48),
        Vector2(0.50, 0.35),
      ],
    ),
    WalkingPathModel(
      id: 'queue_to_counter',
      normalizedPoints: <Vector2>[
        Vector2(0.36, 0.35),
        Vector2(0.50, 0.35),
        Vector2(0.50, 0.30),
      ],
    ),
    WalkingPathModel(
      id: 'counter_to_tables',
      normalizedPoints: <Vector2>[
        Vector2(0.50, 0.34),
        Vector2(0.50, 0.42),
        Vector2(0.50, 0.62),
        Vector2(0.50, 0.80),
      ],
    ),
    WalkingPathModel(
      id: 'staff_service_lane',
      normalizedPoints: <Vector2>[
        Vector2(0.22, 0.20),
        Vector2(0.50, 0.20),
        Vector2(0.78, 0.20),
        Vector2(0.78, 0.42),
        Vector2(0.50, 0.62),
      ],
    ),
  ];

  static StationZoneModel? stationZoneFor(String stationId) {
    for (final zone in stationZones) {
      if (zone.stationId == stationId) {
        return zone;
      }
    }
    return null;
  }
}
