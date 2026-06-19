class EventShopProductConfig {
  const EventShopProductConfig({
    required this.id,
    required this.title,
    required this.costEventBeans,
    required this.rewardCoins,
    required this.rewardGems,
    this.rewardBoostId,
    this.rewardBoostSeconds = 0,
  });

  final String id;
  final String title;
  final int costEventBeans;
  final double rewardCoins;
  final int rewardGems;
  final String? rewardBoostId;
  final int rewardBoostSeconds;
}

const List<EventShopProductConfig> eventShopProducts = <EventShopProductConfig>[
  EventShopProductConfig(id: 'event_coin_pack', title: 'Coin Pack', costEventBeans: 20, rewardCoins: 15000, rewardGems: 0),
  EventShopProductConfig(id: 'event_boost_pack', title: 'Boost Pack', costEventBeans: 25, rewardCoins: 0, rewardGems: 2, rewardBoostId: 'income_boost', rewardBoostSeconds: 300),
  EventShopProductConfig(id: 'event_decor_token', title: 'Decoration Discount Token', costEventBeans: 30, rewardCoins: 5000, rewardGems: 3),
];
