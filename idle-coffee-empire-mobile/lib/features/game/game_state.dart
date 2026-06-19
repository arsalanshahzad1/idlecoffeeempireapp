import '../../models/game_resources.dart';
import '../../models/cafe_order_state.dart';
import '../../models/boost_state.dart';
import '../../models/settings_state.dart';
import '../../models/station_state.dart';
import '../../models/tutorial_state.dart';
import '../../models/daily_reward_state.dart';
import '../../models/login_streak_state.dart';
import '../../models/task_state.dart';
import '../../models/limited_event_state.dart';
import '../../models/notification_preferences.dart';
import '../../models/service_integration_state.dart';

class GameState {
  const GameState({
    required this.coins,
    required this.stations,
    required this.lastSavedAtUtc,
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
    required this.waitingCustomerTypes,
    required this.cafeOrders,
    required this.stationQueues,
    required this.cafeTables,
    required this.servedByCustomerType,
    required this.timesReachedCozyCafeAfterPrestige,
    required this.settings,
    required this.tutorial,
    required this.saveVersion,
    required this.lastSavedAtUtcMillis,
    this.customerSpawnProgressSeconds = 0,
    this.spawnBoostRemainingSeconds = 0,
    this.spawnBoostMultiplier = 1.0,
    this.selectedStationId,
    this.lastOfflineIncome = 0,
    this.saveCorrupted = false,
    this.uiEventCounter = 0,
    this.lastUiEvent = '',
    this.lastUiEventStationId,
    this.activeBoosts = const <String, BoostState>{},
    this.offlineIncomeRewardedClaimed = false,
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
  final Map<String, StationState> stations;
  final DateTime lastSavedAtUtc;
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
  final List<String> waitingCustomerTypes;
  final List<CafeOrderState> cafeOrders;
  final Map<String, List<StationTaskState>> stationQueues;
  final List<CafeTableState> cafeTables;
  final Map<String, int> servedByCustomerType;
  final int timesReachedCozyCafeAfterPrestige;
  final SettingsState settings;
  final TutorialState tutorial;
  final int saveVersion;
  final int lastSavedAtUtcMillis;
  final double customerSpawnProgressSeconds;
  final double spawnBoostRemainingSeconds;
  final double spawnBoostMultiplier;
  final String? selectedStationId;
  final double lastOfflineIncome;
  final bool saveCorrupted;
  final int uiEventCounter;
  final String lastUiEvent;
  final String? lastUiEventStationId;
  final Map<String, BoostState> activeBoosts;
  final bool offlineIncomeRewardedClaimed;
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

  double get coffeeCups => resources.coffeeCups;
  int get servedCustomers => resources.servedCustomers;

  GameState copyWith({
    double? coins,
    Map<String, StationState>? stations,
    DateTime? lastSavedAtUtc,
    GameResources? resources,
    int? waitingCustomers,
    Set<String>? workersHired,
    Map<String, int>? workerLevels,
    int? playerLevel,
    int? currentXp,
    int? gems,
    double? lifetimeCoinsEarned,
    int? lifetimeCustomersServed,
    double? lifetimeCupsProduced,
    int? prestigePoints,
    int? lifetimePrestigePoints,
    int? prestigeCount,
    Set<String>? claimedMilestoneIds,
    Set<String>? completedAchievementIds,
    Set<String>? claimedAchievementIds,
    Set<String>? completedPrestigeAchievementIds,
    Set<String>? claimedPrestigeAchievementIds,
    Map<String, int>? milestoneProgress,
    String? expansionStageId,
    Set<String>? purchasedDecorationIds,
    Set<String>? purchasedManagerIds,
    Set<String>? purchasedPermanentUpgradeIds,
    List<String>? waitingCustomerTypes,
    List<CafeOrderState>? cafeOrders,
    Map<String, List<StationTaskState>>? stationQueues,
    List<CafeTableState>? cafeTables,
    Map<String, int>? servedByCustomerType,
    int? timesReachedCozyCafeAfterPrestige,
    SettingsState? settings,
    TutorialState? tutorial,
    int? saveVersion,
    int? lastSavedAtUtcMillis,
    double? customerSpawnProgressSeconds,
    double? spawnBoostRemainingSeconds,
    double? spawnBoostMultiplier,
    String? selectedStationId,
    bool clearSelection = false,
    double? lastOfflineIncome,
    bool? saveCorrupted,
    int? uiEventCounter,
    String? lastUiEvent,
    String? lastUiEventStationId,
    bool clearLastUiEventStationId = false,
    Map<String, BoostState>? activeBoosts,
    bool? offlineIncomeRewardedClaimed,
    DailyRewardState? dailyReward,
    LoginStreakState? loginStreak,
    Map<String, TaskState>? dailyTasks,
    Map<String, TaskState>? weeklyTasks,
    String? dailyTaskDateKey,
    String? weeklyTaskDateKey,
    LimitedEventState? activeEvents,
    String? selectedThemeId,
    int? eventBeans,
    double? tipsEarned,
    int? tipsReceived,
    int? satisfiedOrders,
    int? failedOrders,
    int? nextOrderSerial,
    NotificationPreferences? notificationPreferences,
    ServiceIntegrationState? serviceIntegration,
  }) {
    return GameState(
      coins: coins ?? this.coins,
      stations: stations ?? this.stations,
      lastSavedAtUtc: lastSavedAtUtc ?? this.lastSavedAtUtc,
      resources: resources ?? this.resources,
      waitingCustomers: waitingCustomers ?? this.waitingCustomers,
      workersHired: workersHired ?? this.workersHired,
      workerLevels: workerLevels ?? this.workerLevels,
      playerLevel: playerLevel ?? this.playerLevel,
      currentXp: currentXp ?? this.currentXp,
      gems: gems ?? this.gems,
      lifetimeCoinsEarned: lifetimeCoinsEarned ?? this.lifetimeCoinsEarned,
      lifetimeCustomersServed: lifetimeCustomersServed ?? this.lifetimeCustomersServed,
      lifetimeCupsProduced: lifetimeCupsProduced ?? this.lifetimeCupsProduced,
      prestigePoints: prestigePoints ?? this.prestigePoints,
      lifetimePrestigePoints: lifetimePrestigePoints ?? this.lifetimePrestigePoints,
      prestigeCount: prestigeCount ?? this.prestigeCount,
      claimedMilestoneIds: claimedMilestoneIds ?? this.claimedMilestoneIds,
      completedAchievementIds: completedAchievementIds ?? this.completedAchievementIds,
      claimedAchievementIds: claimedAchievementIds ?? this.claimedAchievementIds,
      completedPrestigeAchievementIds: completedPrestigeAchievementIds ?? this.completedPrestigeAchievementIds,
      claimedPrestigeAchievementIds: claimedPrestigeAchievementIds ?? this.claimedPrestigeAchievementIds,
      milestoneProgress: milestoneProgress ?? this.milestoneProgress,
      expansionStageId: expansionStageId ?? this.expansionStageId,
      purchasedDecorationIds: purchasedDecorationIds ?? this.purchasedDecorationIds,
      purchasedManagerIds: purchasedManagerIds ?? this.purchasedManagerIds,
      purchasedPermanentUpgradeIds: purchasedPermanentUpgradeIds ?? this.purchasedPermanentUpgradeIds,
      waitingCustomerTypes: waitingCustomerTypes ?? this.waitingCustomerTypes,
      cafeOrders: cafeOrders ?? this.cafeOrders,
      stationQueues: stationQueues ?? this.stationQueues,
      cafeTables: cafeTables ?? this.cafeTables,
      servedByCustomerType: servedByCustomerType ?? this.servedByCustomerType,
      timesReachedCozyCafeAfterPrestige: timesReachedCozyCafeAfterPrestige ?? this.timesReachedCozyCafeAfterPrestige,
      settings: settings ?? this.settings,
      tutorial: tutorial ?? this.tutorial,
      saveVersion: saveVersion ?? this.saveVersion,
      lastSavedAtUtcMillis: lastSavedAtUtcMillis ?? this.lastSavedAtUtcMillis,
      customerSpawnProgressSeconds: customerSpawnProgressSeconds ?? this.customerSpawnProgressSeconds,
      spawnBoostRemainingSeconds: spawnBoostRemainingSeconds ?? this.spawnBoostRemainingSeconds,
      spawnBoostMultiplier: spawnBoostMultiplier ?? this.spawnBoostMultiplier,
      selectedStationId: clearSelection ? null : (selectedStationId ?? this.selectedStationId),
      lastOfflineIncome: lastOfflineIncome ?? this.lastOfflineIncome,
      saveCorrupted: saveCorrupted ?? this.saveCorrupted,
      uiEventCounter: uiEventCounter ?? this.uiEventCounter,
      lastUiEvent: lastUiEvent ?? this.lastUiEvent,
      lastUiEventStationId: clearLastUiEventStationId ? null : (lastUiEventStationId ?? this.lastUiEventStationId),
      activeBoosts: activeBoosts ?? this.activeBoosts,
      offlineIncomeRewardedClaimed: offlineIncomeRewardedClaimed ?? this.offlineIncomeRewardedClaimed,
      dailyReward: dailyReward ?? this.dailyReward,
      loginStreak: loginStreak ?? this.loginStreak,
      dailyTasks: dailyTasks ?? this.dailyTasks,
      weeklyTasks: weeklyTasks ?? this.weeklyTasks,
      dailyTaskDateKey: dailyTaskDateKey ?? this.dailyTaskDateKey,
      weeklyTaskDateKey: weeklyTaskDateKey ?? this.weeklyTaskDateKey,
      activeEvents: activeEvents ?? this.activeEvents,
      selectedThemeId: selectedThemeId ?? this.selectedThemeId,
      eventBeans: eventBeans ?? this.eventBeans,
      tipsEarned: tipsEarned ?? this.tipsEarned,
      tipsReceived: tipsReceived ?? this.tipsReceived,
      satisfiedOrders: satisfiedOrders ?? this.satisfiedOrders,
      failedOrders: failedOrders ?? this.failedOrders,
      nextOrderSerial: nextOrderSerial ?? this.nextOrderSerial,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      serviceIntegration: serviceIntegration ?? this.serviceIntegration,
    );
  }
}
