abstract class CrashService {
  Future<void> recordError(Object error, StackTrace stackTrace, {String reason = ''});
  Future<void> setUserId(String userId);
  Future<void> setCustomKey(String key, Object value);
  Future<void> log(String message);
}
