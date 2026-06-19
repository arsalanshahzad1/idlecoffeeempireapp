import 'asset_registry.dart';
import 'sprite_renderer.dart';

class VisualStateMapper {
  const VisualStateMapper._();

  static SpriteVisualState station(String stationId) {
    return SpriteVisualState(
      idle: AssetRegistry.stationIdle(stationId),
      active: AssetRegistry.stationActive(stationId),
      locked: AssetRegistry.stationLocked(stationId),
      frames: <String>[
        '${AssetRegistry.stationsRoot}/$stationId/anim_0.png',
        '${AssetRegistry.stationsRoot}/$stationId/anim_1.png',
      ],
    );
  }

  static SpriteVisualState customer(String typeId) {
    return SpriteVisualState(
      idle: AssetRegistry.customerIdle(typeId),
      active: AssetRegistry.customerMoving(typeId),
      locked: AssetRegistry.customerWaiting(typeId),
      frames: <String>[
        AssetRegistry.customerIdle(typeId),
        AssetRegistry.customerMoving(typeId),
        AssetRegistry.customerWaiting(typeId),
        AssetRegistry.customerServing(typeId),
      ],
    );
  }

  static SpriteVisualState worker(String workerId) {
    return SpriteVisualState(
      idle: AssetRegistry.workerIdle(workerId),
      active: AssetRegistry.workerWorking(workerId),
      frames: <String>[
        AssetRegistry.workerIdle(workerId),
        AssetRegistry.workerWorking(workerId),
      ],
    );
  }
}
