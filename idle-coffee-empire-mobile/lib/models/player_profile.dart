class PlayerProfile {
  const PlayerProfile({
    required this.playerId,
    required this.username,
    required this.avatarId,
    required this.createdAtUtcMillis,
  });

  final String playerId;
  final String username;
  final String avatarId;
  final int createdAtUtcMillis;

  static PlayerProfile createDefault() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return PlayerProfile(
      playerId: 'player_$now',
      username: 'Coffee Owner',
      avatarId: 'avatar_default',
      createdAtUtcMillis: now,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'playerId': playerId,
      'username': username,
      'avatarId': avatarId,
      'createdAtUtcMillis': createdAtUtcMillis,
    };
  }

  factory PlayerProfile.fromMap(Map<dynamic, dynamic> map) {
    return PlayerProfile(
      playerId: map['playerId'] as String? ?? 'player_unknown',
      username: map['username'] as String? ?? 'Coffee Owner',
      avatarId: map['avatarId'] as String? ?? 'avatar_default',
      createdAtUtcMillis:
          (map['createdAtUtcMillis'] as num?)?.toInt() ??
          DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }
}
