import '../../data/store_product_configs.dart';
import 'iap_service.dart';

class MockIapService implements IapService {
  @override
  Future<List<StoreProduct>> listProducts() async => storeProducts;

  @override
  Future<PurchaseResult> purchase(String productId) async {
    return PurchaseResult(
      success: true,
      productId: productId,
      receipt: 'mock-receipt-$productId-${DateTime.now().millisecondsSinceEpoch}',
      message: 'Mock purchase completed',
    );
  }

  @override
  Future<bool> verifyReceiptPlaceholder(String receipt) async {
    return receipt.startsWith('mock-receipt-');
  }
}
