class ShopTierState {
  const ShopTierState({this.currentTier = 1});

  final int currentTier;

  static const ShopTierState initial = ShopTierState(currentTier: 1);

  ShopTierState copyWith({int? currentTier}) {
    return ShopTierState(currentTier: currentTier ?? this.currentTier);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'currentTier': currentTier};
  }

  factory ShopTierState.fromMap(Map<dynamic, dynamic> map) {
    return ShopTierState(
      currentTier: (map['currentTier'] as num?)?.toInt() ?? 1,
    );
  }
}
