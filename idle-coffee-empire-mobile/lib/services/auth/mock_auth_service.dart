import 'auth_service.dart';

class MockAuthService implements AuthService {
  AuthSession _session = const AuthSession(
    userId: 'guest-local',
    isGuest: true,
  );

  @override
  Future<AuthSession> currentSession() async => _session;

  @override
  Future<AuthSession> linkAccountPlaceholder(String provider) async {
    _session = AuthSession(
      userId: _session.userId,
      isGuest: true,
      linkedProvider: provider,
      syncStatus: 'link_pending',
    );
    return _session;
  }

  @override
  Future<AuthSession> signInGuest() async {
    _session = AuthSession(
      userId: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      isGuest: true,
    );
    return _session;
  }

  @override
  Future<void> signOut() async {
    _session = const AuthSession(userId: 'guest-local', isGuest: true);
  }
}
