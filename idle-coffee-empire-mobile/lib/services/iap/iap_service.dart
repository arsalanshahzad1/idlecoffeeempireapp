enum StoreProductType { consumable, nonConsumable, subscription }

class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.type,
    required this.mockPriceLabel,
    this.gemAmount = 0,
    this.isMockOnly = true,
  });

  final String id;
  final String title;
  final StoreProductType type;
  final String mockPriceLabel;
  final int gemAmount;
  final bool isMockOnly;
}

class PurchaseResult {
  const PurchaseResult({
    required this.success,
    required this.productId,
    required this.receipt,
    this.message = '',
  });

  final bool success;
  final String productId;
  final String receipt;
  final String message;
}

abstract class IapService {
  Future<List<StoreProduct>> listProducts();
  Future<PurchaseResult> purchase(String productId);
  Future<bool> verifyReceiptPlaceholder(String receipt);
}
