import 'crash_service.dart';

class MockCrashService implements CrashService {
  @override
  Future<void> log(String message) async {}

  @override
  Future<void> recordError(Object error, StackTrace stackTrace, {String reason = ''}) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}

  @override
  Future<void> setUserId(String userId) async {}
}
