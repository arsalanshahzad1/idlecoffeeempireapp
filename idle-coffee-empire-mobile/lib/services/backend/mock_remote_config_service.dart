import 'remote_config_service.dart';

class MockRemoteConfigService implements RemoteConfigService {
  final Map<String, Object> _overrides = <String, Object>{};

  @override
  Map<String, Object> allOverrides() {
    return Map<String, Object>.unmodifiable(_overrides);
  }

  @override
  bool getBool(String key, bool fallback) {
    final value = _overrides[key];
    return value is bool ? value : fallback;
  }

  @override
  double getDouble(String key, double fallback) {
    final value = _overrides[key];
    return value is num ? value.toDouble() : fallback;
  }

  @override
  int getInt(String key, int fallback) {
    final value = _overrides[key];
    return value is num ? value.toInt() : fallback;
  }

  @override
  String getString(String key, String fallback) {
    final value = _overrides[key];
    return value is String ? value : fallback;
  }

  @override
  Future<void> refresh() async {
    // TODO(backend): pull updated values from real remote config provider.
  }

  @override
  Future<void> simulateOverride(String key, Object value) async {
    _overrides[key] = value;
  }
}
