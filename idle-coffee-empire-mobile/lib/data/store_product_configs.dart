import '../services/iap/iap_service.dart';

const List<StoreProduct> storeProducts = <StoreProduct>[
  StoreProduct(id: 'gems_small', title: 'Small Gems Pack', type: StoreProductType.consumable, mockPriceLabel: '4.99', gemAmount: 120),
  StoreProduct(id: 'gems_medium', title: 'Medium Gems Pack', type: StoreProductType.consumable, mockPriceLabel: '9.99', gemAmount: 300),
  StoreProduct(id: 'gems_large', title: 'Large Gems Pack', type: StoreProductType.consumable, mockPriceLabel: '19.99', gemAmount: 700),
  StoreProduct(id: 'starter_pack', title: 'Starter Pack', type: StoreProductType.nonConsumable, mockPriceLabel: '3.99'),
  StoreProduct(id: 'remove_ads', title: 'Remove Ads', type: StoreProductType.nonConsumable, mockPriceLabel: '2.99'),
  StoreProduct(id: 'vip_pass', title: 'VIP Pass', type: StoreProductType.subscription, mockPriceLabel: '6.99/mo'),
];
