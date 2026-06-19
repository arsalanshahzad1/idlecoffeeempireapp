class CloudSyncState {
  const CloudSyncState({
    required this.localSaveTimestampUtcMillis,
    required this.remoteSaveTimestampUtcMillis,
    required this.syncVersion,
    required this.deviceId,
    required this.lastSyncStatus,
  });

  final int localSaveTimestampUtcMillis;
  final int remoteSaveTimestampUtcMillis;
  final int syncVersion;
  final String deviceId;
  final String lastSyncStatus;

  static CloudSyncState initial() {
    return const CloudSyncState(
      localSaveTimestampUtcMillis: 0,
      remoteSaveTimestampUtcMillis: 0,
      syncVersion: 1,
      deviceId: 'device_local_placeholder',
      lastSyncStatus: 'never_synced',
    );
  }

  CloudSyncState copyWith({
    int? localSaveTimestampUtcMillis,
    int? remoteSaveTimestampUtcMillis,
    int? syncVersion,
    String? deviceId,
    String? lastSyncStatus,
  }) {
    return CloudSyncState(
      localSaveTimestampUtcMillis:
          localSaveTimestampUtcMillis ?? this.localSaveTimestampUtcMillis,
      remoteSaveTimestampUtcMillis:
          remoteSaveTimestampUtcMillis ?? this.remoteSaveTimestampUtcMillis,
      syncVersion: syncVersion ?? this.syncVersion,
      deviceId: deviceId ?? this.deviceId,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'localSaveTimestampUtcMillis': localSaveTimestampUtcMillis,
      'remoteSaveTimestampUtcMillis': remoteSaveTimestampUtcMillis,
      'syncVersion': syncVersion,
      'deviceId': deviceId,
      'lastSyncStatus': lastSyncStatus,
    };
  }

  factory CloudSyncState.fromMap(Map<dynamic, dynamic> map) {
    return CloudSyncState(
      localSaveTimestampUtcMillis:
          (map['localSaveTimestampUtcMillis'] as num?)?.toInt() ?? 0,
      remoteSaveTimestampUtcMillis:
          (map['remoteSaveTimestampUtcMillis'] as num?)?.toInt() ?? 0,
      syncVersion: (map['syncVersion'] as num?)?.toInt() ?? 1,
      deviceId: map['deviceId'] as String? ?? 'device_local_placeholder',
      lastSyncStatus: map['lastSyncStatus'] as String? ?? 'never_synced',
    );
  }
}

class CloudSaveEnvelope {
  const CloudSaveEnvelope({
    required this.payload,
    required this.syncState,
    required this.schemaVersion,
  });

  final Map<String, dynamic> payload;
  final CloudSyncState syncState;
  final int schemaVersion;
}
