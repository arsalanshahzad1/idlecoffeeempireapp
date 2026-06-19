class ServiceIntegrationState {
  const ServiceIntegrationState({
    this.removeAds = false,
    this.vipPass = false,
    this.mockPurchases = const <String>{},
    this.adCooldownsUtcMillis = const <String, int>{},
    this.lastMockCloudSyncUtcMillis = 0,
    this.profileSyncStatus = 'guest',
    this.lastReceiptVerificationStatus = 'pending',
  });

  final bool removeAds;
  final bool vipPass;
  final Set<String> mockPurchases;
  final Map<String, int> adCooldownsUtcMillis;
  final int lastMockCloudSyncUtcMillis;
  final String profileSyncStatus;
  final String lastReceiptVerificationStatus;

  ServiceIntegrationState copyWith({
    bool? removeAds,
    bool? vipPass,
    Set<String>? mockPurchases,
    Map<String, int>? adCooldownsUtcMillis,
    int? lastMockCloudSyncUtcMillis,
    String? profileSyncStatus,
    String? lastReceiptVerificationStatus,
  }) {
    return ServiceIntegrationState(
      removeAds: removeAds ?? this.removeAds,
      vipPass: vipPass ?? this.vipPass,
      mockPurchases: mockPurchases ?? this.mockPurchases,
      adCooldownsUtcMillis: adCooldownsUtcMillis ?? this.adCooldownsUtcMillis,
      lastMockCloudSyncUtcMillis:
          lastMockCloudSyncUtcMillis ?? this.lastMockCloudSyncUtcMillis,
      profileSyncStatus: profileSyncStatus ?? this.profileSyncStatus,
      lastReceiptVerificationStatus:
          lastReceiptVerificationStatus ?? this.lastReceiptVerificationStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'removeAds': removeAds,
      'vipPass': vipPass,
      'mockPurchases': mockPurchases.toList(growable: false),
      'adCooldownsUtcMillis': adCooldownsUtcMillis,
      'lastMockCloudSyncUtcMillis': lastMockCloudSyncUtcMillis,
      'profileSyncStatus': profileSyncStatus,
      'lastReceiptVerificationStatus': lastReceiptVerificationStatus,
    };
  }

  factory ServiceIntegrationState.fromMap(Map<dynamic, dynamic> map) {
    final purchases = <String>{};
    final rawPurchases = map['mockPurchases'];
    if (rawPurchases is List) {
      for (final value in rawPurchases) {
        if (value is String) purchases.add(value);
      }
    }
    final cooldowns = <String, int>{};
    final rawCooldowns = map['adCooldownsUtcMillis'];
    if (rawCooldowns is Map) {
      for (final entry in rawCooldowns.entries) {
        if (entry.key is String && entry.value is num) {
          cooldowns[entry.key as String] = (entry.value as num).toInt();
        }
      }
    }
    return ServiceIntegrationState(
      removeAds: map['removeAds'] as bool? ?? false,
      vipPass: map['vipPass'] as bool? ?? false,
      mockPurchases: purchases,
      adCooldownsUtcMillis: cooldowns,
      lastMockCloudSyncUtcMillis:
          (map['lastMockCloudSyncUtcMillis'] as num?)?.toInt() ?? 0,
      profileSyncStatus: map['profileSyncStatus'] as String? ?? 'guest',
      lastReceiptVerificationStatus:
          map['lastReceiptVerificationStatus'] as String? ?? 'pending',
    );
  }
}
