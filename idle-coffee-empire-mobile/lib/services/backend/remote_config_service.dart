abstract class RemoteConfigService {
  Future<void> refresh();
  int getInt(String key, int fallback);
  double getDouble(String key, double fallback);
  bool getBool(String key, bool fallback);
  String getString(String key, String fallback);
  Future<void> simulateOverride(String key, Object value);
  Map<String, Object> allOverrides();
}
