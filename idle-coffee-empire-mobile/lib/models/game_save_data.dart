import 'boost_state.dart';
import 'cafe_order_state.dart';
import 'daily_reward_state.dart';
import 'game_resources.dart';
import 'limited_event_state.dart';
import 'login_streak_state.dart';
import 'notification_preferences.dart';
import 'service_integration_state.dart';
import 'station_state.dart';
import 'task_state.dart';

class GameSaveData {
  static const int currentSaveVersion = 8;

  const GameSaveData({
    required this.saveVersion,
    required this.coins,
    required this.lastSavedAtUtcMillis,
    required this.stations,
    required this.resources,
    required this.waitingCustomers,
    required this.workersHired,
    required this.workerLevels,
    required this.playerLevel,
    required this.currentXp,
    required this.gems,
    required this.lifetimeCoinsEarned,
    required this.lifetimeCustomersServed,
    required this.lifetimeCupsProduced,
    required this.prestigePoints,
    required this.lifetimePrestigePoints,
    required this.prestigeCount,
    required this.claimedMilestoneIds,
    required this.completedAchievementIds,
    required this.claimedAchievementIds,
    required this.completedPrestigeAchievementIds,
    required this.claimedPrestigeAchievementIds,
    required this.milestoneProgress,
    required this.expansionStageId,
    required this.purchasedDecorationIds,
    required this.purchasedManagerIds,
    required this.purchasedPermanentUpgradeIds,
    required this.cafeOrders,
    required this.stationQueues,
    required this.cafeTables,
    required this.servedByCustomerType,
    required this.timesReachedCozyCafeAfterPrestige,
    this.customerSpawnProgressSeconds = 0,
    this.spawnBoostRemainingSeconds = 0,
    this.spawnBoostMultiplier = 1.0,
    this.activeBoosts = const <String, BoostState>{},
    this.dailyReward = DailyRewardState.initial,
    this.loginStreak = LoginStreakState.initial,
    this.dailyTasks = const <String, TaskState>{},
    this.weeklyTasks = const <String, TaskState>{},
    this.dailyTaskDateKey = '',
    this.weeklyTaskDateKey = '',
    this.activeEvents = LimitedEventState.initial,
    this.selectedThemeId = 'default_coffee',
    this.eventBeans = 0,
    this.tipsEarned = 0,
    this.tipsReceived = 0,
    this.satisfiedOrders = 0,
    this.failedOrders = 0,
    this.nextOrderSerial = 1,
    this.notificationPreferences = NotificationPreferences.defaults,
    this.serviceIntegration = const ServiceIntegrationState(),
  });

  final double coins;
  final int saveVersion;
  final int lastSavedAtUtcMillis;
  final Map<String, StationState> stations;
  final GameResources resources;
  final int waitingCustomers;
  final Set<String> workersHired;
  final Map<String, int> workerLevels;
  final int playerLevel;
  final int currentXp;
  final int gems;
  final double lifetimeCoinsEarned;
  final int lifetimeCustomersServed;
  final double lifetimeCupsProduced;
  final int prestigePoints;
  final int lifetimePrestigePoints;
  final int prestigeCount;
  final Set<String> claimedMilestoneIds;
  final Set<String> completedAchievementIds;
  final Set<String> claimedAchievementIds;
  final Set<String> completedPrestigeAchievementIds;
  final Set<String> claimedPrestigeAchievementIds;
  final Map<String, int> milestoneProgress;
  final String expansionStageId;
  final Set<String> purchasedDecorationIds;
  final Set<String> purchasedManagerIds;
  final Set<String> purchasedPermanentUpgradeIds;
  final List<CafeOrderState> cafeOrders;
  final Map<String, List<StationTaskState>> stationQueues;
  final List<CafeTableState> cafeTables;
  final Map<String, int> servedByCustomerType;
  final int timesReachedCozyCafeAfterPrestige;
  final double customerSpawnProgressSeconds;
  final double spawnBoostRemainingSeconds;
  final double spawnBoostMultiplier;
  final Map<String, BoostState> activeBoosts;
  final DailyRewardState dailyReward;
  final LoginStreakState loginStreak;
  final Map<String, TaskState> dailyTasks;
  final Map<String, TaskState> weeklyTasks;
  final String dailyTaskDateKey;
  final String weeklyTaskDateKey;
  final LimitedEventState activeEvents;
  final String selectedThemeId;
  final int eventBeans;
  final double tipsEarned;
  final int tipsReceived;
  final int satisfiedOrders;
  final int failedOrders;
  final int nextOrderSerial;
  final NotificationPreferences notificationPreferences;
  final ServiceIntegrationState serviceIntegration;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'coins': coins,
      'saveVersion': saveVersion,
      'lastSavedAtUtcMillis': lastSavedAtUtcMillis,
      'stations': stations.map((key, value) => MapEntry(key, value.toMap())),
      'resources': resources.toMap(),
      'waitingCustomers': waitingCustomers,
      'workersHired': workersHired.toList(growable: false),
      'workerLevels': workerLevels,
      'playerLevel': playerLevel,
      'currentXp': currentXp,
      'gems': gems,
      'lifetimeCoinsEarned': lifetimeCoinsEarned,
      'lifetimeCustomersServed': lifetimeCustomersServed,
      'lifetimeCupsProduced': lifetimeCupsProduced,
      'prestigePoints': prestigePoints,
      'lifetimePrestigePoints': lifetimePrestigePoints,
      'prestigeCount': prestigeCount,
      'claimedMilestoneIds': claimedMilestoneIds.toList(growable: false),
      'completedAchievementIds': completedAchievementIds.toList(growable: false),
      'claimedAchievementIds': claimedAchievementIds.toList(growable: false),
      'completedPrestigeAchievementIds': completedPrestigeAchievementIds.toList(growable: false),
      'claimedPrestigeAchievementIds': claimedPrestigeAchievementIds.toList(growable: false),
      'milestoneProgress': milestoneProgress,
      'expansionStageId': expansionStageId,
      'purchasedDecorationIds': purchasedDecorationIds.toList(growable: false),
      'purchasedManagerIds': purchasedManagerIds.toList(growable: false),
      'purchasedPermanentUpgradeIds': purchasedPermanentUpgradeIds.toList(growable: false),
      'cafeOrders': cafeOrders.map((order) => order.toMap()).toList(growable: false),
      'stationQueues': stationQueues.map(
        (key, value) => MapEntry(key, value.map((task) => task.toMap()).toList(growable: false)),
      ),
      'cafeTables': cafeTables.map((table) => table.toMap()).toList(growable: false),
      'servedByCustomerType': servedByCustomerType,
      'timesReachedCozyCafeAfterPrestige': timesReachedCozyCafeAfterPrestige,
      'customerSpawnProgressSeconds': customerSpawnProgressSeconds,
      'spawnBoostRemainingSeconds': spawnBoostRemainingSeconds,
      'spawnBoostMultiplier': spawnBoostMultiplier,
      'activeBoosts': activeBoosts.map((key, value) => MapEntry(key, value.toMap())),
      'dailyReward': dailyReward.toMap(),
      'loginStreak': loginStreak.toMap(),
      'dailyTasks': dailyTasks.map((key, value) => MapEntry(key, value.toMap())),
      'weeklyTasks': weeklyTasks.map((key, value) => MapEntry(key, value.toMap())),
      'dailyTaskDateKey': dailyTaskDateKey,
      'weeklyTaskDateKey': weeklyTaskDateKey,
      'activeEvents': activeEvents.toMap(),
      'selectedThemeId': selectedThemeId,
      'eventBeans': eventBeans,
      'tipsEarned': tipsEarned,
      'tipsReceived': tipsReceived,
      'satisfiedOrders': satisfiedOrders,
      'failedOrders': failedOrders,
      'nextOrderSerial': nextOrderSerial,
      'notificationPreferences': notificationPreferences.toMap(),
      'serviceIntegration': serviceIntegration.toMap(),
    };
  }

  factory GameSaveData.fromMap(Map<dynamic, dynamic> map) {
    final stationMap = <String, StationState>{};
    final rawStations = map['stations'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{};
    for (final entry in rawStations.entries) {
      stationMap[entry.key as String] = StationState.fromMap(entry.value as Map<dynamic, dynamic>);
    }

    Set<String> asStringSet(dynamic raw) {
      final set = <String>{};
      if (raw is List) {
        for (final value in raw) {
          if (value is String) set.add(value);
        }
      }
      return set;
    }

    Map<String, int> asIntMap(dynamic raw) {
      final result = <String, int>{};
      if (raw is Map) {
        for (final entry in raw.entries) {
          if (entry.key is String && entry.value is num) {
            result[entry.key as String] = (entry.value as num).toInt();
          }
        }
      }
      return result;
    }

    Map<String, TaskState> asTaskMap(dynamic raw) {
      final result = <String, TaskState>{};
      if (raw is Map) {
        for (final entry in raw.entries) {
          if (entry.key is String && entry.value is Map) {
            result[entry.key as String] = TaskState.fromMap(entry.value as Map<dynamic, dynamic>);
          }
        }
      }
      return result;
    }

    List<CafeOrderState> asOrderList(dynamic raw) {
      final result = <CafeOrderState>[];
      if (raw is List) {
        for (final value in raw) {
          if (value is Map) {
            result.add(CafeOrderState.fromMap(value));
          }
        }
      }
      return result;
    }

    Map<String, List<StationTaskState>> asStationQueues(dynamic raw) {
      final result = <String, List<StationTaskState>>{};
      if (raw is Map) {
        for (final entry in raw.entries) {
          if (entry.key is! String || entry.value is! List) {
            continue;
          }
          result[entry.key as String] = <StationTaskState>[
            for (final value in entry.value as List)
              if (value is Map) StationTaskState.fromMap(value),
          ];
        }
      }
      return result;
    }

    List<CafeTableState> asTableList(dynamic raw) {
      final result = <CafeTableState>[];
      if (raw is List) {
        for (final value in raw) {
          if (value is Map) {
            result.add(CafeTableState.fromMap(value));
          }
        }
      }
      return result;
    }

    final activeBoosts = <String, BoostState>{};
    final rawBoosts = map['activeBoosts'];
    if (rawBoosts is Map) {
      for (final entry in rawBoosts.entries) {
        if (entry.key is String && entry.value is Map) {
          activeBoosts[entry.key as String] = BoostState.fromMap(entry.value as Map<dynamic, dynamic>);
        }
      }
    }

    final rawResources = map['resources'];
    final resources = rawResources is Map<dynamic, dynamic>
        ? GameResources.fromMap(rawResources)
        : GameResources(
            coffeeCups: (map['coffeeCups'] as num?)?.toDouble() ?? 0,
            servedCustomers: (map['servedCustomers'] as num?)?.toInt() ?? 0,
          );

    final rawDailyReward = map['dailyReward'];
    final rawLoginStreak = map['loginStreak'];
    final rawEvents = map['activeEvents'];
    final rawNotification = map['notificationPreferences'];
    final rawIntegration = map['serviceIntegration'];

    return GameSaveData(
      saveVersion: (map['saveVersion'] as num?)?.toInt() ?? 1,
      coins: (map['coins'] as num?)?.toDouble() ?? 0,
      lastSavedAtUtcMillis: (map['lastSavedAtUtcMillis'] as num?)?.toInt() ?? DateTime.now().toUtc().millisecondsSinceEpoch,
      stations: stationMap,
      resources: resources,
      waitingCustomers: (map['waitingCustomers'] as num?)?.toInt() ?? 0,
      workersHired: asStringSet(map['workersHired']),
      workerLevels: asIntMap(map['workerLevels']),
      playerLevel: (map['playerLevel'] as num?)?.toInt() ?? 1,
      currentXp: (map['currentXp'] as num?)?.toInt() ?? 0,
      gems: (map['gems'] as num?)?.toInt() ?? 0,
      lifetimeCoinsEarned: (map['lifetimeCoinsEarned'] as num?)?.toDouble() ?? (map['coins'] as num?)?.toDouble() ?? 0,
      lifetimeCustomersServed: (map['lifetimeCustomersServed'] as num?)?.toInt() ?? resources.servedCustomers,
      lifetimeCupsProduced: (map['lifetimeCupsProduced'] as num?)?.toDouble() ?? resources.coffeeCups,
      prestigePoints: (map['prestigePoints'] as num?)?.toInt() ?? 0,
      lifetimePrestigePoints: (map['lifetimePrestigePoints'] as num?)?.toInt() ?? 0,
      prestigeCount: (map['prestigeCount'] as num?)?.toInt() ?? 0,
      claimedMilestoneIds: asStringSet(map['claimedMilestoneIds']),
      completedAchievementIds: asStringSet(map['completedAchievementIds']),
      claimedAchievementIds: asStringSet(map['claimedAchievementIds']),
      completedPrestigeAchievementIds: asStringSet(map['completedPrestigeAchievementIds']),
      claimedPrestigeAchievementIds: asStringSet(map['claimedPrestigeAchievementIds']),
      milestoneProgress: asIntMap(map['milestoneProgress']),
      expansionStageId: map['expansionStageId'] as String? ?? 'small_cart',
      purchasedDecorationIds: asStringSet(map['purchasedDecorationIds']),
      purchasedManagerIds: asStringSet(map['purchasedManagerIds']),
      purchasedPermanentUpgradeIds: asStringSet(map['purchasedPermanentUpgradeIds']),
      cafeOrders: asOrderList(map['cafeOrders']),
      stationQueues: asStationQueues(map['stationQueues']),
      cafeTables: asTableList(map['cafeTables']),
      servedByCustomerType: asIntMap(map['servedByCustomerType']),
      timesReachedCozyCafeAfterPrestige: (map['timesReachedCozyCafeAfterPrestige'] as num?)?.toInt() ?? 0,
      customerSpawnProgressSeconds: (map['customerSpawnProgressSeconds'] as num?)?.toDouble() ?? 0,
      spawnBoostRemainingSeconds: (map['spawnBoostRemainingSeconds'] as num?)?.toDouble() ?? 0,
      spawnBoostMultiplier: (map['spawnBoostMultiplier'] as num?)?.toDouble() ?? 1,
      activeBoosts: activeBoosts,
      dailyReward: rawDailyReward is Map ? DailyRewardState.fromMap(rawDailyReward) : DailyRewardState.initial,
      loginStreak: rawLoginStreak is Map ? LoginStreakState.fromMap(rawLoginStreak) : LoginStreakState.initial,
      dailyTasks: asTaskMap(map['dailyTasks']),
      weeklyTasks: asTaskMap(map['weeklyTasks']),
      dailyTaskDateKey: map['dailyTaskDateKey'] as String? ?? '',
      weeklyTaskDateKey: map['weeklyTaskDateKey'] as String? ?? '',
      activeEvents: rawEvents is Map ? LimitedEventState.fromMap(rawEvents) : LimitedEventState.initial,
      selectedThemeId: map['selectedThemeId'] as String? ?? 'default_coffee',
      eventBeans: (map['eventBeans'] as num?)?.toInt() ?? 0,
      tipsEarned: (map['tipsEarned'] as num?)?.toDouble() ?? 0,
      tipsReceived: (map['tipsReceived'] as num?)?.toInt() ?? 0,
      satisfiedOrders: (map['satisfiedOrders'] as num?)?.toInt() ?? 0,
      failedOrders: (map['failedOrders'] as num?)?.toInt() ?? 0,
      nextOrderSerial: (map['nextOrderSerial'] as num?)?.toInt() ?? 1,
      notificationPreferences: rawNotification is Map ? NotificationPreferences.fromMap(rawNotification) : NotificationPreferences.defaults,
      serviceIntegration: rawIntegration is Map ? ServiceIntegrationState.fromMap(rawIntegration) : const ServiceIntegrationState(),
    );
  }
}
