import '../../models/game_save_data.dart';

class BackendUserProfileContract {
  const BackendUserProfileContract({required this.userId, required this.username});
  final String userId;
  final String username;
}

class CloudSaveUploadContract {
  const CloudSaveUploadContract({required this.userId, required this.saveData});
  final String userId;
  final GameSaveData saveData;
}

class DeviceSyncContract {
  const DeviceSyncContract({required this.deviceId, required this.lastSyncUtcMillis});
  final String deviceId;
  final int lastSyncUtcMillis;
}

class EconomySnapshotContract {
  const EconomySnapshotContract({required this.userId, required this.coins, required this.servedCustomers});
  final String userId;
  final double coins;
  final int servedCustomers;
}

class PurchaseReceiptVerificationContract {
  const PurchaseReceiptVerificationContract({required this.userId, required this.productId, required this.receipt});
  final String userId;
  final String productId;
  final String receipt;
}

class AnalyticsEventBatchContract {
  const AnalyticsEventBatchContract({required this.userId, required this.events});
  final String userId;
  final List<Map<String, Object?>> events;
}

class LiveEventConfigContract {
  const LiveEventConfigContract({required this.id, required this.enabled, required this.modifiers});
  final String id;
  final bool enabled;
  final Map<String, Object> modifiers;
}

class RemoteConfigPayloadContract {
  const RemoteConfigPayloadContract({required this.values});
  final Map<String, Object> values;
}
