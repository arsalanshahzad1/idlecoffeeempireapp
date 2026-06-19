import '../../models/backend_contracts.dart';
import 'backend_api_client.dart';

class MockBackendApiClient implements BackendApiClient {
  @override
  Future<BackendUserProfileContract?> fetchUserProfile(String userId) async {
    return BackendUserProfileContract(userId: userId, username: 'Guest');
  }

  @override
  Future<RemoteConfigPayloadContract> fetchRemoteConfig() async {
    return const RemoteConfigPayloadContract(values: <String, Object>{});
  }

  @override
  Future<bool> submitAnalyticsBatch(AnalyticsEventBatchContract payload) async => true;

  @override
  Future<bool> submitEconomySnapshot(EconomySnapshotContract payload) async => true;

  @override
  Future<bool> uploadCloudSave(CloudSaveUploadContract payload) async => true;

  @override
  Future<bool> verifyPurchaseReceipt(PurchaseReceiptVerificationContract payload) async => true;
}
