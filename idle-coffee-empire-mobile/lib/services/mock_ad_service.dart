import 'ad_service.dart';

class MockAdService extends AdService {
  const MockAdService();

  @override
  Future<bool> showRewarded({
    required RewardedPlacement placement,
  }) async {
    // TODO(admob): Replace with real rewarded ad loading/show logic.
    // Keep this API contract stable so placement reward handling remains in controller.
    return true;
  }
}
