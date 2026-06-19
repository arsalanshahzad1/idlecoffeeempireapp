class AuthSession {
  const AuthSession({
    required this.userId,
    required this.isGuest,
    this.linkedProvider = 'none',
    this.syncStatus = 'local_only',
  });

  final String userId;
  final bool isGuest;
  final String linkedProvider;
  final String syncStatus;
}

abstract class AuthService {
  Future<AuthSession> currentSession();
  Future<AuthSession> signInGuest();
  Future<AuthSession> linkAccountPlaceholder(String provider);
  Future<void> signOut();
}
