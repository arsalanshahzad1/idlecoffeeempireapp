class AssetRegistry {
  AssetRegistry._();

  static const String imagesRoot = 'assets/images';
  static const String uiRoot = '$imagesRoot/ui';
  static const String stationsRoot = '$imagesRoot/stations';
  static const String workersRoot = '$imagesRoot/workers';
  static const String customersRoot = '$imagesRoot/customers';
  static const String decorationsRoot = '$imagesRoot/decorations';
  static const String floorsRoot = '$imagesRoot/floors';
  static const String themesRoot = '$imagesRoot/themes';
  static const String effectsRoot = '$imagesRoot/effects';
  static const String animationsRoot = 'assets/animations';
  static const String sfxRoot = 'assets/audio/sfx';
  static const String musicRoot = 'assets/audio/music';

  static String stationIdle(String stationId) => '$stationsRoot/$stationId/idle.png';
  static String stationActive(String stationId) => '$stationsRoot/$stationId/active.png';
  static String stationLocked(String stationId) => '$stationsRoot/$stationId/locked.png';

  static String customerIdle(String typeId) => '$customersRoot/$typeId/idle.png';
  static String customerMoving(String typeId) => '$customersRoot/$typeId/moving.png';
  static String customerWaiting(String typeId) => '$customersRoot/$typeId/waiting.png';
  static String customerServing(String typeId) => '$customersRoot/$typeId/serving.png';

  static String workerIdle(String workerId) => '$workersRoot/$workerId/idle.png';
  static String workerWorking(String workerId) => '$workersRoot/$workerId/working.png';

  static String floorForTheme(String themeId) => '$floorsRoot/$themeId/floor.png';
  static const String starterCafeMap = '$floorsRoot/starter_cafe/base_shop_layout.png';
  static String hudForTheme(String themeId) => '$themesRoot/$themeId/hud.png';

  static List<String> stationFallbackCandidates(String stationId, {required bool unlocked, required bool active}) {
    if (!unlocked) {
      return <String>[stationLocked(stationId), stationIdle(stationId)];
    }
    if (active) {
      return <String>[stationActive(stationId), stationIdle(stationId)];
    }
    return <String>[stationIdle(stationId), stationActive(stationId)];
  }
}
