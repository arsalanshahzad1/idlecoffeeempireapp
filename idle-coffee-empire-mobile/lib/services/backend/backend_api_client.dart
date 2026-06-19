import '../../models/backend_contracts.dart';

abstract class BackendApiClient {
  Future<BackendUserProfileContract?> fetchUserProfile(String userId);
  Future<bool> uploadCloudSave(CloudSaveUploadContract payload);
  Future<bool> submitEconomySnapshot(EconomySnapshotContract payload);
  Future<bool> verifyPurchaseReceipt(PurchaseReceiptVerificationContract payload);
  Future<bool> submitAnalyticsBatch(AnalyticsEventBatchContract payload);
  Future<RemoteConfigPayloadContract> fetchRemoteConfig();
}
