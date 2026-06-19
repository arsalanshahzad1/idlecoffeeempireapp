import 'package:flame/components.dart';

import '../visuals/asset_registry.dart';

class MapConstants {
  MapConstants._();

  static const String starterCafeAsset = AssetRegistry.starterCafeMap;
  static final Vector2 sourceSize = Vector2(1024, 1536);
  static const double sourceAspectRatio = 1024 / 1536;
  static const double screenPadding = 10;
  static const double minMapWidth = 300;
  static const double maxMapWidth = 620;
  static const double topHudReserveCompact = 86;
  static const double topHudReserveRegular = 96;
  static const double bottomPanelReserveCompact = 154;
  static const double bottomPanelReserveRegular = 166;
}
