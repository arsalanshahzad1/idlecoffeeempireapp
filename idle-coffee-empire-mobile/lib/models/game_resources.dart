class GameResources {
  const GameResources({
    required this.coffeeCups,
    required this.servedCustomers,
  });

  final double coffeeCups;
  final int servedCustomers;

  GameResources copyWith({
    double? coffeeCups,
    int? servedCustomers,
  }) {
    return GameResources(
      coffeeCups: coffeeCups ?? this.coffeeCups,
      servedCustomers: servedCustomers ?? this.servedCustomers,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'coffeeCups': coffeeCups,
      'servedCustomers': servedCustomers,
    };
  }

  factory GameResources.fromMap(Map<dynamic, dynamic> map) {
    return GameResources(
      coffeeCups: (map['coffeeCups'] as num?)?.toDouble() ?? 0,
      servedCustomers: (map['servedCustomers'] as num?)?.toInt() ?? 0,
    );
  }
}
