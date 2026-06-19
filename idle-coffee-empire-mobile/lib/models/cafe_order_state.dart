class CafeOrderItemState {
  const CafeOrderItemState({
    required this.itemId,
    required this.stationId,
    required this.label,
    required this.icon,
    this.produced = false,
    this.delivered = false,
  });

  final String itemId;
  final String stationId;
  final String label;
  final String icon;
  final bool produced;
  final bool delivered;

  CafeOrderItemState copyWith({
    bool? produced,
    bool? delivered,
  }) {
    return CafeOrderItemState(
      itemId: itemId,
      stationId: stationId,
      label: label,
      icon: icon,
      produced: produced ?? this.produced,
      delivered: delivered ?? this.delivered,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemId': itemId,
      'stationId': stationId,
      'label': label,
      'icon': icon,
      'produced': produced,
      'delivered': delivered,
    };
  }

  factory CafeOrderItemState.fromMap(Map<dynamic, dynamic> map) {
    return CafeOrderItemState(
      itemId: map['itemId'] as String? ?? 'item',
      stationId: map['stationId'] as String? ?? 'espresso_machine',
      label: map['label'] as String? ?? 'Coffee',
      icon: map['icon'] as String? ?? 'ESP',
      produced: map['produced'] as bool? ?? false,
      delivered: map['delivered'] as bool? ?? false,
    );
  }
}

class CafeOrderState {
  const CafeOrderState({
    required this.orderId,
    required this.customerId,
    required this.customerTypeId,
    required this.requestedItems,
    required this.orderValue,
    required this.tipChance,
    required this.patienceSeconds,
    required this.maxPatienceSeconds,
    required this.phase,
    this.tableId,
    this.elapsedSeconds = 0,
    this.tipAwarded = 0,
  });

  final String orderId;
  final String customerId;
  final String customerTypeId;
  final List<CafeOrderItemState> requestedItems;
  final double orderValue;
  final double tipChance;
  final double patienceSeconds;
  final double maxPatienceSeconds;
  final double elapsedSeconds;
  final String phase;
  final String? tableId;
  final double tipAwarded;

  int get deliveredCount => requestedItems.where((item) => item.delivered).length;
  int get totalCount => requestedItems.length;
  bool get isComplete => totalCount > 0 && deliveredCount >= totalCount;
  bool get isActive => phase == CafeOrderPhase.seated || phase == CafeOrderPhase.ordering;

  CafeOrderState copyWith({
    List<CafeOrderItemState>? requestedItems,
    double? patienceSeconds,
    double? elapsedSeconds,
    String? phase,
    String? tableId,
    bool clearTableId = false,
    double? tipAwarded,
  }) {
    return CafeOrderState(
      orderId: orderId,
      customerId: customerId,
      customerTypeId: customerTypeId,
      requestedItems: requestedItems ?? this.requestedItems,
      orderValue: orderValue,
      tipChance: tipChance,
      patienceSeconds: patienceSeconds ?? this.patienceSeconds,
      maxPatienceSeconds: maxPatienceSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      phase: phase ?? this.phase,
      tableId: clearTableId ? null : (tableId ?? this.tableId),
      tipAwarded: tipAwarded ?? this.tipAwarded,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'customerId': customerId,
      'customerTypeId': customerTypeId,
      'requestedItems': requestedItems.map((item) => item.toMap()).toList(growable: false),
      'orderValue': orderValue,
      'tipChance': tipChance,
      'patienceSeconds': patienceSeconds,
      'maxPatienceSeconds': maxPatienceSeconds,
      'elapsedSeconds': elapsedSeconds,
      'phase': phase,
      'tableId': tableId,
      'tipAwarded': tipAwarded,
    };
  }

  factory CafeOrderState.fromMap(Map<dynamic, dynamic> map) {
    final rawItems = map['requestedItems'];
    final items = <CafeOrderItemState>[];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is Map) {
          items.add(CafeOrderItemState.fromMap(raw));
        }
      }
    }
    return CafeOrderState(
      orderId: map['orderId'] as String? ?? 'order',
      customerId: map['customerId'] as String? ?? 'customer',
      customerTypeId: map['customerTypeId'] as String? ?? 'regular',
      requestedItems: items,
      orderValue: (map['orderValue'] as num?)?.toDouble() ?? 0,
      tipChance: (map['tipChance'] as num?)?.toDouble() ?? 0.15,
      patienceSeconds: (map['patienceSeconds'] as num?)?.toDouble() ?? 60,
      maxPatienceSeconds: (map['maxPatienceSeconds'] as num?)?.toDouble() ?? 60,
      elapsedSeconds: (map['elapsedSeconds'] as num?)?.toDouble() ?? 0,
      phase: map['phase'] as String? ?? CafeOrderPhase.seated,
      tableId: map['tableId'] as String?,
      tipAwarded: (map['tipAwarded'] as num?)?.toDouble() ?? 0,
    );
  }
}

class StationTaskState {
  const StationTaskState({
    required this.taskId,
    required this.orderId,
    required this.customerId,
    required this.stationId,
    required this.itemId,
    required this.itemLabel,
    required this.itemIcon,
    this.progressSeconds = 0,
    this.produced = false,
    this.delivered = false,
  });

  final String taskId;
  final String orderId;
  final String customerId;
  final String stationId;
  final String itemId;
  final String itemLabel;
  final String itemIcon;
  final double progressSeconds;
  final bool produced;
  final bool delivered;

  StationTaskState copyWith({
    double? progressSeconds,
    bool? produced,
    bool? delivered,
  }) {
    return StationTaskState(
      taskId: taskId,
      orderId: orderId,
      customerId: customerId,
      stationId: stationId,
      itemId: itemId,
      itemLabel: itemLabel,
      itemIcon: itemIcon,
      progressSeconds: progressSeconds ?? this.progressSeconds,
      produced: produced ?? this.produced,
      delivered: delivered ?? this.delivered,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'taskId': taskId,
      'orderId': orderId,
      'customerId': customerId,
      'stationId': stationId,
      'itemId': itemId,
      'itemLabel': itemLabel,
      'itemIcon': itemIcon,
      'progressSeconds': progressSeconds,
      'produced': produced,
      'delivered': delivered,
    };
  }

  factory StationTaskState.fromMap(Map<dynamic, dynamic> map) {
    return StationTaskState(
      taskId: map['taskId'] as String? ?? 'task',
      orderId: map['orderId'] as String? ?? 'order',
      customerId: map['customerId'] as String? ?? 'customer',
      stationId: map['stationId'] as String? ?? 'espresso_machine',
      itemId: map['itemId'] as String? ?? 'item',
      itemLabel: map['itemLabel'] as String? ?? 'Coffee',
      itemIcon: map['itemIcon'] as String? ?? 'ESP',
      progressSeconds: (map['progressSeconds'] as num?)?.toDouble() ?? 0,
      produced: map['produced'] as bool? ?? false,
      delivered: map['delivered'] as bool? ?? false,
    );
  }
}

class CafeTableState {
  const CafeTableState({
    required this.tableId,
    required this.isUnlocked,
    this.customerId,
  });

  final String tableId;
  final bool isUnlocked;
  final String? customerId;

  bool get isOccupied => customerId != null;

  CafeTableState copyWith({
    bool? isUnlocked,
    String? customerId,
    bool clearCustomerId = false,
  }) {
    return CafeTableState(
      tableId: tableId,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      customerId: clearCustomerId ? null : (customerId ?? this.customerId),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tableId': tableId,
      'isUnlocked': isUnlocked,
      'customerId': customerId,
    };
  }

  factory CafeTableState.fromMap(Map<dynamic, dynamic> map) {
    return CafeTableState(
      tableId: map['tableId'] as String? ?? 'table',
      isUnlocked: map['isUnlocked'] as bool? ?? true,
      customerId: map['customerId'] as String?,
    );
  }
}

class CafeOrderPhase {
  static const String ordering = 'ordering';
  static const String seated = 'seated';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String leaving = 'leaving';
}
