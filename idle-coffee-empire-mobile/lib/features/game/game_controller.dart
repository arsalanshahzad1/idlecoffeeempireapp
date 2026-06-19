import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/economy_balance_config.dart';
import '../../data/monetization_config.dart';
import '../../data/prestige_balance_config.dart';
import '../../data/progression_balance_config.dart';
import '../../data/store_product_configs.dart';
import '../../data/event_shop_configs.dart';
import '../../data/task_configs.dart';
import '../../data/theme_configs.dart';
import '../../data/station_configs.dart';
import '../../data/tutorial_steps.dart';
import '../../managers/achievement_manager.dart';
import '../../managers/customer_type_manager.dart';
import '../../managers/decoration_manager.dart';
import '../../managers/economy_manager.dart';
import '../../managers/expansion_manager.dart';
import '../../managers/daily_reward_manager.dart';
import '../../managers/limited_event_manager.dart';
import '../../managers/manager_upgrade_manager.dart';
import '../../managers/milestone_manager.dart';
import '../../managers/permanent_upgrade_manager.dart';
import '../../managers/prestige_achievement_manager.dart';
import '../../managers/station_bonus_manager.dart';
import '../../managers/worker_manager.dart';
import '../../managers/task_manager.dart';
import '../../models/decoration_config.dart';
import '../../models/expansion_config.dart';
import '../../models/game_resources.dart';
import '../../models/game_save_data.dart';
import '../../models/cafe_order_state.dart';
import '../../models/milestone_state.dart';
import '../../models/permanent_upgrade_state.dart';
import '../../models/prestige_achievement_state.dart';
import '../../models/station_config.dart';
import '../../models/station_milestone_bonus.dart';
import '../../models/station_state.dart';
import '../../models/boost_state.dart';
import '../../models/login_streak_state.dart';
import '../../models/notification_preferences.dart';
import '../../models/worker_config.dart';
import '../../models/achievement_state.dart';
import '../../models/manager_config.dart';
import '../../models/task_state.dart';
import '../../services/save_service.dart';
import '../../services/settings_service.dart';
import '../../services/audio_service.dart';
import '../../services/ad_service.dart';
import '../../services/haptics_service.dart';
import '../../services/analytics/analytics_event.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/backend/economy_sync_service.dart';
import '../../services/backend/remote_config_service.dart';
import '../../services/backend/user_profile_service.dart';
import '../../services/backend/backend_api_client.dart';
import '../../services/cloud/cloud_save_service.dart';
import '../../services/cloud/sync_models.dart';
import '../../services/liveops/live_event_manager.dart';
import '../../services/liveops/live_event_model.dart';
import '../../services/liveops/mock_live_event_manager.dart';
import '../../services/notification/notification_service.dart';
import '../../services/iap/iap_service.dart';
import '../../services/crash/crash_service.dart';
import '../../services/auth/auth_service.dart';
import '../../app/services/service_providers.dart';
import '../../systems/offline_income_system.dart';
import '../../systems/station_manager.dart';
import 'game_state.dart';
import '../../managers/tutorial_manager.dart';
import '../../models/settings_state.dart';
import '../../models/tutorial_state.dart';
import '../../managers/boost_manager.dart';
import '../../models/player_profile.dart';

final gameControllerProvider =
    StateNotifierProvider<GameController, GameState>((ref) {
      final controller = GameController(
        const EconomyManager(),
        const StationManager(),
        const OfflineIncomeSystem(),
        const WorkerManager(),
        const StationBonusManager(),
        const MilestoneManager(),
        const ExpansionManager(),
        const DecorationManager(),
        const DailyRewardManager(),
        const LimitedEventManager(),
        const CustomerTypeManager(),
        const ManagerUpgradeManager(),
        const AchievementManager(),
        const TaskManager(),
        const PermanentUpgradeManager(),
        const PrestigeAchievementManager(),
        SaveService(),
        SettingsService(),
        const TutorialManager(),
        const AudioService(),
        ref.read(adServiceProvider),
        const BoostManager(),
        const HapticsService(),
        ref.read(analyticsServiceProvider),
        ref.read(remoteConfigServiceProvider),
        ref.read(cloudSaveServiceProvider),
        MockLiveEventManager(),
        ref.read(notificationServiceProvider),
        ref.read(userProfileServiceProvider),
        ref.read(economySyncServiceProvider),
        ref.read(iapServiceProvider),
        ref.read(crashServiceProvider),
        ref.read(authServiceProvider),
        ref.read(backendApiClientProvider),
      );
      Future<void>.microtask(controller.bootstrap);
      return controller;
    });

class GameController extends StateNotifier<GameState> {
  GameController(
    this._economy,
    this._stationManager,
    this._offlineIncomeSystem,
    this._workerManager,
    this._stationBonusManager,
    this._milestoneManager,
    this._expansionManager,
    this._decorationManager,
    this._dailyRewardManager,
    this._limitedEventManager,
    this._customerTypeManager,
    this._managerUpgradeManager,
    this._achievementManager,
    this._taskManager,
    this._permanentUpgradeManager,
    this._prestigeAchievementManager,
    this._saveService,
    this._settingsService,
    this._tutorialManager,
    this._audioService,
    this._adService,
    this._boostManager,
    this._hapticsService,
    this._analyticsService,
    this._remoteConfigService,
    this._cloudSaveService,
    this._liveEventManager,
    this._notificationService,
    this._userProfileService,
    this._economySyncService,
    this._iapService,
    this._crashService,
    this._authService,
    this._backendApiClient,
  ) : super(_initialState(DateTime.now().toUtc()));

  final EconomyManager _economy;
  final StationManager _stationManager;
  final OfflineIncomeSystem _offlineIncomeSystem;
  final WorkerManager _workerManager;
  final StationBonusManager _stationBonusManager;
  final MilestoneManager _milestoneManager;
  final ExpansionManager _expansionManager;
  final DecorationManager _decorationManager;
  final DailyRewardManager _dailyRewardManager;
  final LimitedEventManager _limitedEventManager;
  final CustomerTypeManager _customerTypeManager;
  final ManagerUpgradeManager _managerUpgradeManager;
  final AchievementManager _achievementManager;
  final TaskManager _taskManager;
  final PermanentUpgradeManager _permanentUpgradeManager;
  final PrestigeAchievementManager _prestigeAchievementManager;
  final SaveService _saveService;
  final SettingsService _settingsService;
  final TutorialManager _tutorialManager;
  final AudioService _audioService;
  final AdService _adService;
  final BoostManager _boostManager;
  final HapticsService _hapticsService;
  final AnalyticsService _analyticsService;
  final RemoteConfigService _remoteConfigService;
  final CloudSaveService _cloudSaveService;
  final LiveEventManager _liveEventManager;
  final NotificationService _notificationService;
  final UserProfileService _userProfileService;
  final EconomySyncService _economySyncService;
  final IapService _iapService;
  final CrashService _crashService;
  final AuthService _authService;
  final BackendApiClient _backendApiClient;
  final math.Random _random = math.Random();
  Timer? _autosaveTimer;
  bool _loaded = false;
  bool _stateCommitQueued = false;
  GameState? _queuedState;
  CloudSyncState _cloudSyncState = CloudSyncState.initial();
  PlayerProfile _playerProfile = PlayerProfile.createDefault();
  static const double _devCoinGrant = 50000000;

  bool get loaded => _loaded;
  GameState get currentState => state;
  List<MilestoneState> get milestones => _milestoneManager.buildMilestones(state);
  ExpansionConfig get currentExpansion => _expansionManager.byId(state.expansionStageId);
  List<DecorationConfig> get decorationConfigs => _decorationManager.all;
  int get xpToNextLevel => ProgressionBalanceConfig.xpToNextLevel(state.playerLevel);
  int get potentialPrestigePoints {
    final totalPotential =
        PrestigeBalanceConfig.potentialPointsFromLifetimeCoins(state.lifetimeCoinsEarned);
    final remaining = totalPotential - state.lifetimePrestigePoints;
    return remaining > 0 ? remaining : 0;
  }
  double get currentPrestigeMultiplier =>
      PrestigeBalanceConfig.multiplierFromPoints(state.prestigePoints);
  double get nextPrestigeMultiplier => PrestigeBalanceConfig.multiplierFromPoints(
    state.prestigePoints + potentialPrestigePoints,
  );
  double get prestigeMultiplierEstimate => PrestigeBalanceConfig.multiplierFromPoints(
    state.prestigePoints + potentialPrestigePoints,
  );
  bool get canPrestige => potentialPrestigePoints > 0;
  List<ManagerConfig> get managerConfigs => _managerUpgradeManager.all;
  List<AchievementState> get achievements => _achievementManager.buildAchievements(state);
  List<PermanentUpgradeState> get permanentUpgrades =>
      _permanentUpgradeManager.buildStates(state.purchasedPermanentUpgradeIds);
  List<PrestigeAchievementState> get prestigeAchievements =>
      _prestigeAchievementManager.buildAchievements(state);
  int get gems => state.gems;
  List<BoostConfig> get boostConfigs => _boostManager.all;
  SettingsState get settings => state.settings;
  TutorialState get tutorial => state.tutorial;
  List<TutorialStep> get tutorialSteps => _tutorialManager.steps;
  CloudSyncState get cloudSyncState => _cloudSyncState;
  PlayerProfile get playerProfile => _playerProfile;
  int get queuedEconomySnapshots => _economySyncService.queuedCount();
  Map<String, Object> get remoteConfigOverrides => _remoteConfigService.allOverrides();
  int get coinPackSmallGemCost => _remoteConfigService.getInt(
    'store.coin_pack_small_gem_cost',
    MonetizationConfig.coinPackSmallGemCost,
  );
  int get stationSkipGemCost => _remoteConfigService.getInt(
    'store.station_skip_gem_cost',
    MonetizationConfig.stationSkipGemCost,
  );
  int get rewardedGemAmount => _remoteConfigService.getInt(
    'ads.rewarded_gem_amount',
    MonetizationConfig.rewardedGemAmount,
  );

  int boostRemainingSeconds(String boostId) {
    final boost = state.activeBoosts[boostId];
    if (boost == null) {
      return 0;
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final remaining = ((boost.expiresAtUtcMillis - now) / 1000).floor();
    return remaining > 0 ? remaining : 0;
  }

  double get totalCoinsPerSecond {
    final nowUtc = DateTime.now().toUtc();
    final boostIncome = _boostManager.activeIncomeMultiplier(state.activeBoosts, nowUtc);
    var total = 0.0;
    for (final config in stationConfigs) {
      final station = state.stations[config.id];
      if (station == null || !station.isUnlocked || !station.autoEnabled) {
        continue;
      }
      final profit = _economy.profitPerTap(config, station) *
          _stationBonusManager.profitMultiplier(config.id, station.level) *
          (config.id == 'espresso_machine'
              ? _limitedEventManager.combinedEspressoProfit(state.activeEvents)
              : 1.0) *
          _globalIncomeMultiplier(nowUtc: nowUtc) *
          boostIncome;
      final speed = _stationSpeedMultiplier(config.id, station.level);
      final boostSpeed = _boostManager.activeProductionSpeedMultiplier(
        state.activeBoosts,
        nowUtc,
      );
      final worker = _workerManager.forStation(config.id);
      final workerBoost = (worker != null && isWorkerHired(worker.id))
          ? _workerManager.efficiencyForLevel(worker, workerLevel(worker.id))
          : 0.0;
      final permanentWorkerMultiplier = _permanentUpgradeManager.workerEfficiencyMultiplier(
        state.purchasedPermanentUpgradeIds,
      );
      final rateBoost =
          1 + (workerBoost * permanentWorkerMultiplier) *
              EconomyBalanceConfig.workerAutomationRateMultiplier;
      final seconds = config.productionTimeSeconds / (speed * rateBoost * boostSpeed);
      total += profit / seconds;
    }
    return total;
  }

  StationConfig configFor(String stationId) {
    return stationConfigs.firstWhere((s) => s.id == stationId);
  }

  WorkerConfig? workerForStation(String stationId) {
    return _workerManager.forStation(stationId);
  }
  List<WorkerConfig> get workerConfigs => _workerManager.allWorkers;

  WorkerConfig? workerById(String workerId) {
    return _workerManager.byId(workerId);
  }

  bool isManagerUnlocked(String managerId) {
    final cfg = _managerUpgradeManager.byId(managerId);
    if (cfg == null) {
      return false;
    }
    return _managerUpgradeManager.isUnlocked(state, cfg);
  }

  String? managerUnlockReason(String managerId) {
    final cfg = _managerUpgradeManager.byId(managerId);
    if (cfg == null) {
      return 'Locked';
    }
    if (state.purchasedManagerIds.contains(managerId)) {
      return 'Already purchased';
    }
    if (!_managerUpgradeManager.isUnlocked(state, cfg)) {
      final stationReq = cfg.unlock.stationLevel;
      if (stationReq != null) {
        return 'Requires Level ${stationReq.level}';
      }
      return 'Locked';
    }
    if (state.coins < cfg.cost) {
      return 'Not enough coins';
    }
    return null;
  }

  int workerLevel(String workerId) {
    return state.workerLevels[workerId] ?? 1;
  }

  bool isWorkerHired(String workerId) {
    return state.workersHired.contains(workerId);
  }

  int cookCountForStation(String stationId) {
    final worker = _workerManager.forStation(stationId);
    if (worker == null || !isWorkerHired(worker.id)) {
      return 1;
    }
    return (workerLevel(worker.id) + 1).clamp(1, 3).toInt();
  }

  double workerUpgradeCost(String workerId) {
    final worker = _workerManager.byId(workerId);
    if (worker == null) {
      return 0;
    }
    return _workerManager.upgradeCost(worker, workerLevel(workerId));
  }

  StationMilestoneBonus? nextStationMilestone(String stationId, int level) {
    return _stationBonusManager.nextMilestone(stationId, level);
  }

  Future<void> bootstrap() async {
    await SaveService.init().timeout(const Duration(seconds: 8), onTimeout: () {});
    await SettingsService.init().timeout(const Duration(seconds: 8), onTimeout: () {});
    await _remoteConfigService.refresh();
    await _backendApiClient.fetchRemoteConfig();
    _playerProfile = await _userProfileService.loadOrCreateProfile();
    await _authService.signInGuest();
    await _crashService.setUserId(_playerProfile.playerId);
    _cloudSyncState = await _cloudSaveService.getSyncState();
    final saveLoad = await _saveService.load().timeout(
      const Duration(seconds: 8),
      onTimeout: () => const SaveLoadResult(data: null, corrupted: false),
    );
    final loadedData = saveLoad.data;
    final loadedSettings = await _settingsService.loadSettings();
    final loadedTutorial = await _settingsService.loadTutorial();
    final now = DateTime.now().toUtc();
    final todayKey = _dateKey(now);

    if (loadedData == null) {
      _setStateSafely(
        _withDevCoinGrant(_initialState(now)).copyWith(
          settings: loadedSettings,
          tutorial: loadedTutorial,
          saveCorrupted: saveLoad.corrupted,
        ),
      );
      _rollTaskWindows(todayKey: todayKey);
      unawaited(_persist());
    } else {
      final loadedStations = loadedData.stations.isEmpty
          ? _stationManager.createDefaultStates()
          : _ensureAllStations(loadedData.stations);
      final loadedState = GameState(
        coins: loadedData.coins,
        stations: loadedStations,
        lastSavedAtUtc: DateTime.fromMillisecondsSinceEpoch(
          loadedData.lastSavedAtUtcMillis,
          isUtc: true,
        ),
        resources: loadedData.resources,
        waitingCustomers: loadedData.waitingCustomers.clamp(
          0,
          _maxQueueCustomersForState(_initialState(now)),
        ).toInt(),
        waitingCustomerTypes: _defaultQueueTypes(
          loadedData.waitingCustomers,
        ),
        workersHired: loadedData.workersHired,
        workerLevels: loadedData.workerLevels,
        playerLevel: loadedData.playerLevel < 1 ? 1 : loadedData.playerLevel,
        currentXp: loadedData.currentXp,
        gems: loadedData.gems,
        lifetimeCoinsEarned: loadedData.lifetimeCoinsEarned,
        lifetimeCustomersServed: loadedData.lifetimeCustomersServed,
        lifetimeCupsProduced: loadedData.lifetimeCupsProduced,
        prestigePoints: loadedData.prestigePoints,
        lifetimePrestigePoints: loadedData.lifetimePrestigePoints,
        prestigeCount: loadedData.prestigeCount,
        claimedMilestoneIds: loadedData.claimedMilestoneIds,
        completedAchievementIds: loadedData.completedAchievementIds,
        claimedAchievementIds: loadedData.claimedAchievementIds,
        completedPrestigeAchievementIds: loadedData.completedPrestigeAchievementIds,
        claimedPrestigeAchievementIds: loadedData.claimedPrestigeAchievementIds,
        milestoneProgress: loadedData.milestoneProgress,
        expansionStageId: loadedData.expansionStageId,
        purchasedDecorationIds: loadedData.purchasedDecorationIds,
        purchasedManagerIds: loadedData.purchasedManagerIds,
        purchasedPermanentUpgradeIds: loadedData.purchasedPermanentUpgradeIds,
        cafeOrders: loadedData.cafeOrders,
        stationQueues: loadedData.stationQueues,
        cafeTables: loadedData.cafeTables,
        servedByCustomerType: loadedData.servedByCustomerType,
        timesReachedCozyCafeAfterPrestige: loadedData.timesReachedCozyCafeAfterPrestige,
        customerSpawnProgressSeconds: loadedData.customerSpawnProgressSeconds,
        spawnBoostRemainingSeconds: loadedData.spawnBoostRemainingSeconds,
        spawnBoostMultiplier: loadedData.spawnBoostMultiplier,
        activeBoosts: _boostManager.sanitize(
          loadedData.activeBoosts,
          now,
        ),
        offlineIncomeRewardedClaimed: true,
        settings: loadedSettings,
        tutorial: loadedTutorial,
        saveVersion: loadedData.saveVersion,
        lastSavedAtUtcMillis: loadedData.lastSavedAtUtcMillis,
        saveCorrupted: saveLoad.corrupted,
        dailyReward: _dailyRewardManager.rollDay(loadedData.dailyReward, now),
        loginStreak: _nextLoginStreak(loadedData.loginStreak, now),
        dailyTasks: loadedData.dailyTasks,
        weeklyTasks: loadedData.weeklyTasks,
        dailyTaskDateKey: loadedData.dailyTaskDateKey,
        weeklyTaskDateKey: loadedData.weeklyTaskDateKey,
        activeEvents: loadedData.activeEvents,
        selectedThemeId: loadedData.selectedThemeId,
        eventBeans: loadedData.eventBeans,
        tipsEarned: loadedData.tipsEarned,
        tipsReceived: loadedData.tipsReceived,
        satisfiedOrders: loadedData.satisfiedOrders,
        failedOrders: loadedData.failedOrders,
        nextOrderSerial: loadedData.nextOrderSerial,
        notificationPreferences: loadedData.notificationPreferences,
        serviceIntegration: loadedData.serviceIntegration,
      );
      final offlineAward = _calculateOfflineAward(loadedState, now);
      var hydratedState = loadedState.copyWith(
        coins: loadedState.coins + offlineAward,
        lifetimeCoinsEarned: loadedState.lifetimeCoinsEarned + offlineAward,
        lastSavedAtUtc: now,
        lastOfflineIncome: offlineAward,
        offlineIncomeRewardedClaimed: offlineAward <= 0,
      );
      hydratedState = _applyExpansionStage(_withDevCoinGrant(hydratedState));
      _setStateSafely(hydratedState);
      _rollTaskWindows(todayKey: todayKey);
      unawaited(_persist());
    }

    _loaded = true;
    _startAutosaveTimer();
    _logAnalytics(AnalyticsEventType.appOpen);
    _logAnalytics(AnalyticsEventType.sessionStart);
  }

  void _startAutosaveTimer() {
    _autosaveTimer?.cancel();
    final seconds = state.settings.autosaveIntervalSeconds.clamp(10, 120);
    _autosaveTimer = Timer.periodic(Duration(seconds: seconds), (_) => _persist());
  }

  void selectStation(String stationId) {
    _setStateSafely(state.copyWith(selectedStationId: stationId));
  }

  void clearSelection() {
    _setStateSafely(state.copyWith(clearSelection: true));
  }

  Future<void> updateSettings(SettingsState next) async {
    _setStateSafely(state.copyWith(settings: next));
    await _settingsService.saveSettings(next);
    _startAutosaveTimer();
  }

  Future<void> skipTutorial() async {
    final next = _tutorialManager.skip(state.tutorial);
    _setStateSafely(state.copyWith(tutorial: next));
    await _settingsService.saveTutorial(next);
  }

  Future<void> restartTutorial() async {
    final next = _tutorialManager.restart();
    _setStateSafely(state.copyWith(tutorial: next));
    await _settingsService.saveTutorial(next);
  }

  Future<void> _completeTutorialStep(String stepId) async {
    final next = _tutorialManager.completeStep(state.tutorial, stepId);
    if (next == state.tutorial) {
      return;
    }
    _setStateSafely(state.copyWith(tutorial: next));
    _logAnalytics(AnalyticsEventType.tutorialStepComplete, <String, Object?>{'stepId': stepId});
    await _settingsService.saveTutorial(next);
  }

  Future<void> completeTutorialStep(String stepId) => _completeTutorialStep(stepId);

  Future<void> addDebugCoins(double amount) async {
    final safeAmount = amount < 0 ? 0 : amount;
    _setStateSafely(
      state.copyWith(
        coins: state.coins + safeAmount,
        lifetimeCoinsEarned: state.lifetimeCoinsEarned + safeAmount,
      ),
    );
    await _persist();
  }

  Future<void> addDebugCups(double amount) async {
    final safeAmount = amount < 0 ? 0 : amount;
    _setStateSafely(
      state.copyWith(
        resources: state.resources.copyWith(
          coffeeCups: state.coffeeCups + safeAmount,
        ),
        lifetimeCupsProduced: state.lifetimeCupsProduced + safeAmount,
      ),
    );
    await _persist();
  }

  Future<void> addDebugGems(int amount) async {
    if (amount == 0) {
      return;
    }
    final nextGems = (state.gems + amount).clamp(0, 999999999).toInt();
    _setStateSafely(state.copyWith(gems: nextGems));
    await _persist();
  }

  Future<void> addDebugPrestigePoints(int amount) async {
    if (amount == 0) {
      return;
    }
    final next = (state.prestigePoints + amount).clamp(0, 999999999).toInt();
    _setStateSafely(state.copyWith(prestigePoints: next));
    await _persist();
  }

  Future<void> addEventBeansDebug(int amount) async {
    if (amount == 0) {
      return;
    }
    final nextBeans = (state.eventBeans + amount).clamp(0, 999999).toInt();
    _setStateSafely(state.copyWith(eventBeans: nextBeans));
    await _persist();
  }

  Future<void> clearActiveBoosts() async {
    _setStateSafely(state.copyWith(activeBoosts: const <String, BoostState>{}));
    await _persist();
  }

  Future<void> fastForwardTimeSeconds(int seconds) async {
    if (seconds <= 0) {
      return;
    }
    final now = DateTime.now().toUtc();
    final from = now.subtract(Duration(seconds: seconds));
    final bonus = _offlineIncomeSystem.calculate(
      totalCoinsPerSecond: totalCoinsPerSecond,
      fromUtc: from,
      toUtc: now,
      offlineMultiplier: EconomyBalanceConfig.offlineMultiplier,
    );
    _setStateSafely(
      state.copyWith(
        coins: state.coins + bonus,
        lifetimeCoinsEarned: state.lifetimeCoinsEarned + bonus,
        lastOfflineIncome: bonus,
        offlineIncomeRewardedClaimed: bonus <= 0,
      ),
    );
    await _persist();
  }

  Future<void> simulateCloudSync() async {
    _cloudSyncState = await _cloudSaveService.simulateSync();
    _setStateSafely(
      state.copyWith(
        uiEventCounter: state.uiEventCounter + 1,
        serviceIntegration: state.serviceIntegration.copyWith(
          lastMockCloudSyncUtcMillis:
              DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      ),
    );
  }

  Future<void> simulateRemoteConfigOverride({
    required String key,
    required Object value,
  }) async {
    await _remoteConfigService.simulateOverride(key, value);
    _setStateSafely(state.copyWith(uiEventCounter: state.uiEventCounter + 1));
  }

  Future<void> simulateLiveEvent() async {
    await _liveEventManager.simulateEvent(
      const LiveEventModel(
        id: 'weekend_income_boost',
        title: 'Weekend Boost',
        description: 'Mock local event toggled from debug panel.',
        multiplier: 1.2,
        isActive: true,
      ),
    );
    final nextEvents = _limitedEventManager.toggle(
      state.activeEvents,
      'double_espresso_weekend',
      true,
    );
    _setStateSafely(_withUiEvent(state.copyWith(activeEvents: nextEvents), event: 'mock_event_triggered'));
    _logAnalytics(AnalyticsEventType.eventActivated, <String, Object?>{'eventId': 'double_espresso_weekend'});
  }

  Future<List<LiveEventModel>> activeLiveEvents() {
    return _liveEventManager.getActiveEvents();
  }

  bool canClaimDailyReward() {
    final rolled = _dailyRewardManager.rollDay(state.dailyReward, DateTime.now().toUtc());
    return _dailyRewardManager.canClaim(rolled, DateTime.now().toUtc());
  }

  Future<bool> claimDailyReward() async {
    final now = DateTime.now().toUtc();
    final rolled = _dailyRewardManager.rollDay(state.dailyReward, now);
    if (!_dailyRewardManager.canClaim(rolled, now)) {
      return false;
    }
    final reward = _dailyRewardManager.getCurrentReward(rolled);
    var next = state.copyWith(
      coins: state.coins + reward.coins,
      lifetimeCoinsEarned: state.lifetimeCoinsEarned + reward.coins,
      gems: state.gems + reward.gems,
      prestigePoints: state.prestigePoints + reward.prestigePoints,
      dailyReward: _dailyRewardManager.markClaimed(rolled, now),
    );
    if (reward.boostId != null && reward.boostDurationSeconds > 0) {
      final config = _boostManager.byId(reward.boostId!);
      if (config != null) {
        final activated = _boostManager.activate(
          existing: next.activeBoosts,
          config: config,
          nowUtc: now,
        );
        next = next.copyWith(activeBoosts: activated);
      }
    }
    _setStateSafely(next);
    _logAnalytics(AnalyticsEventType.dailyRewardClaimed, <String, Object?>{'day': reward.day});
    await _persist();
    return true;
  }

  Future<void> setLimitedEventActive(String eventId, bool active) async {
    final next = _limitedEventManager.toggle(state.activeEvents, eventId, active);
    _setStateSafely(state.copyWith(activeEvents: next));
    if (active) {
      _logAnalytics(AnalyticsEventType.eventActivated, <String, Object?>{'eventId': eventId});
    }
    await _persist();
  }

  Future<void> setTheme(String themeId) async {
    _setStateSafely(state.copyWith(selectedThemeId: themeId));
    _logAnalytics(AnalyticsEventType.themeChanged, <String, Object?>{'themeId': themeId});
    await _persist();
  }

  Future<void> updateNotificationPreferences(NotificationPreferences preferences) async {
    _setStateSafely(state.copyWith(notificationPreferences: preferences));
    if (preferences.offlineIncomeReminder) {
      await _notificationService.scheduleOfflineIncomeReminder();
    }
    if (preferences.dailyRewardReminder) {
      await _notificationService.scheduleDailyRewardReminder();
    }
    if (preferences.eventReminder) {
      await _notificationService.scheduleEventReminder();
    }
    if (preferences.prestigeAvailableReminder) {
      await _notificationService.schedulePrestigeAvailableReminder();
    }
    await _persist();
  }

  Future<List<StoreProduct>> listStoreProducts() => _iapService.listProducts();

  Future<bool> purchaseMockStoreProduct(String productId) async {
    final result = await _iapService.purchase(productId);
    if (!result.success) {
      return false;
    }
    final verified = await _iapService.verifyReceiptPlaceholder(result.receipt);
    StoreProduct? product;
    for (final p in storeProducts) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }
    var integration = state.serviceIntegration.copyWith(
      mockPurchases: Set<String>.from(state.serviceIntegration.mockPurchases)..add(productId),
      lastReceiptVerificationStatus: verified ? 'verified_mock' : 'failed_mock',
    );
    if (productId == 'remove_ads') {
      integration = integration.copyWith(removeAds: true);
    } else if (productId == 'vip_pass') {
      integration = integration.copyWith(vipPass: true);
    }
    _setStateSafely(
      state.copyWith(
        gems: state.gems + (product?.gemAmount ?? 0),
        serviceIntegration: integration,
      ),
    );
    _logAnalytics(AnalyticsEventType.storePurchaseMock, <String, Object?>{'productId': productId});
    await _persist();
    return true;
  }

  Future<void> linkAccountPlaceholder(String provider) async {
    final session = await _authService.linkAccountPlaceholder(provider);
    _setStateSafely(
      state.copyWith(
        serviceIntegration: state.serviceIntegration.copyWith(
          profileSyncStatus: session.syncStatus,
        ),
      ),
    );
    await _persist();
  }

  bool claimTaskReward(String taskId) {
    TaskConfig? config;
    for (final item in dailyTaskConfigs) {
      if (item.id == taskId) {
        config = item;
        break;
      }
    }
    config ??= weeklyTaskConfigs.where((item) => item.id == taskId).isNotEmpty
        ? weeklyTaskConfigs.firstWhere((item) => item.id == taskId)
        : null;
    if (config == null) {
      return false;
    }
    final isDaily = config.type == TaskType.daily;
    final tasks = isDaily ? Map<String, TaskState>.from(state.dailyTasks) : Map<String, TaskState>.from(state.weeklyTasks);
    final current = tasks[taskId];
    if (current == null || current.claimed || current.progress < config.target) {
      return false;
    }
    tasks[taskId] = current.copyWith(claimed: true);
    var nextState = state.copyWith(
        coins: state.coins + config.rewardCoins,
        lifetimeCoinsEarned: state.lifetimeCoinsEarned + config.rewardCoins,
        gems: state.gems + config.rewardGems,
        eventBeans: state.eventBeans + config.rewardEventBeans,
        dailyTasks: isDaily ? tasks : state.dailyTasks,
        weeklyTasks: isDaily ? state.weeklyTasks : tasks,
      );
    if (isDaily) {
      nextState = _addTaskMetric(nextState, 'daily_tasks_completed', 1);
    }
    _setStateSafely(nextState);
    _logAnalytics(AnalyticsEventType.taskCompleted, <String, Object?>{'taskId': taskId});
    unawaited(_persist());
    return true;
  }

  bool purchaseEventShopProduct(String productId) {
    EventShopProductConfig? product;
    for (final item in eventShopProducts) {
      if (item.id == productId) {
        product = item;
        break;
      }
    }
    if (product == null || state.eventBeans < product.costEventBeans) {
      return false;
    }
    var next = state.copyWith(
      eventBeans: state.eventBeans - product.costEventBeans,
      coins: state.coins + product.rewardCoins,
      lifetimeCoinsEarned: state.lifetimeCoinsEarned + product.rewardCoins,
      gems: state.gems + product.rewardGems,
    );
    if (product.rewardBoostId != null && product.rewardBoostSeconds > 0) {
      final config = _boostManager.byId(product.rewardBoostId!);
      if (config != null) {
        next = next.copyWith(
          activeBoosts: _boostManager.activate(
            existing: next.activeBoosts,
            config: config,
            nowUtc: DateTime.now().toUtc(),
          ),
        );
      }
    }
    _setStateSafely(next);
    _logAnalytics(AnalyticsEventType.eventShopPurchase, <String, Object?>{'productId': productId});
    unawaited(_persist());
    return true;
  }

  List<BoostState> activeBoosts() {
    final now = DateTime.now().toUtc();
    final list = state.activeBoosts.values.where((b) => b.isActiveAt(now)).toList();
    list.sort((a, b) => a.expiresAtUtcMillis.compareTo(b.expiresAtUtcMillis));
    return list;
  }

  bool isOfflineRewardAdAvailable() {
    return state.lastOfflineIncome > 0 && !state.offlineIncomeRewardedClaimed;
  }

  Future<bool> claimOfflineDoubleRewarded() async {
    if (!isOfflineRewardAdAvailable()) {
      return false;
    }
    final ok = await _adService.showRewarded(
      placement: RewardedPlacement.doubleOfflineIncome,
    );
    if (!ok) {
      return false;
    }
    final bonus = state.lastOfflineIncome * (MonetizationConfig.offlineDoubleMultiplier - 1);
    _setStateSafely(
      _withUiEvent(
        state.copyWith(
          coins: state.coins + bonus,
          lifetimeCoinsEarned: state.lifetimeCoinsEarned + bonus,
          offlineIncomeRewardedClaimed: true,
        ),
        event: 'offline_doubled',
      ),
    );
    _audioService.playCoin(enabled: state.settings.soundEnabled);
    _logAnalytics(AnalyticsEventType.adRewardClaim, <String, Object?>{'placement': 'instant_coins'});
    await _persist();
    return true;
  }

  Future<bool> watchAdForInstantCoins() async {
    final ok = await _adService.showRewarded(
      placement: RewardedPlacement.instantCoinsBonus,
    );
    if (!ok) {
      return false;
    }
    final reward = totalCoinsPerSecond * MonetizationConfig.rewardedInstantCoinSecondsWorth;
    _setStateSafely(
      _withUiEvent(
        state.copyWith(
          coins: state.coins + reward,
          lifetimeCoinsEarned: state.lifetimeCoinsEarned + reward,
        ),
        event: 'ad_instant_coins',
      ),
    );
    _audioService.playCoin(enabled: state.settings.soundEnabled);
    _logAnalytics(AnalyticsEventType.adRewardClaim, <String, Object?>{'placement': 'free_gems'});
    await _persist();
    return true;
  }

  Future<bool> watchAdForGems() async {
    final ok = await _adService.showRewarded(
      placement: RewardedPlacement.freeGems,
    );
    if (!ok) {
      return false;
    }
    _setStateSafely(
      _withUiEvent(
        state.copyWith(gems: state.gems + rewardedGemAmount),
        event: 'ad_free_gems',
      ),
    );
    _audioService.playCoin(enabled: state.settings.soundEnabled);
    await _persist();
    return true;
  }

  Future<bool> watchAdForSpeedBoost() async {
    final ok = await _adService.showRewarded(
      placement: RewardedPlacement.speedBoost,
    );
    if (!ok) {
      return false;
    }
    final now = DateTime.now().toUtc();
    final boosted = _boostManager.activate(
      existing: _boostManager.sanitize(state.activeBoosts, now),
      config: MonetizationConfig.productionBoost,
      nowUtc: now,
    );
    final nextState = _addTaskMetric(
      state.copyWith(activeBoosts: boosted),
      'boosts_activated',
      1,
    );
    _setStateSafely(_withUiEvent(nextState, event: 'ad_speed_boost'));
    _audioService.playUpgrade(enabled: state.settings.soundEnabled);
    _logAnalytics(AnalyticsEventType.adRewardClaim, <String, Object?>{'placement': 'speed_boost'});
    _logAnalytics(AnalyticsEventType.boostActivation, <String, Object?>{
      'boostId': MonetizationConfig.productionBoost.id,
      'source': 'rewarded_ad',
    });
    await _persist();
    return true;
  }

  Future<bool> watchAdToSkipStationTimer(String stationId) async {
    final station = state.stations[stationId];
    if (station == null || !station.isUnlocked || !station.autoEnabled) {
      return false;
    }
    final ok = await _adService.showRewarded(
      placement: RewardedPlacement.skipStationTimer,
    );
    if (!ok) {
      return false;
    }
    final config = configFor(stationId);
    final now = DateTime.now().toUtc();
    final boostSpeed = _boostManager.activeProductionSpeedMultiplier(state.activeBoosts, now);
    final speed = _stationSpeedMultiplier(stationId, station.level) * boostSpeed;
    final seconds = (config.productionTimeSeconds / speed).clamp(0.5, 999999.0);
    final updated = Map<String, StationState>.from(state.stations);
    updated[stationId] = station.copyWith(
      autoProgressSeconds: station.autoProgressSeconds + seconds,
      isProducing: true,
    );
    _setStateSafely(_withUiEvent(state.copyWith(stations: updated), event: 'ad_skip_timer'));
    _audioService.playUpgrade(enabled: state.settings.soundEnabled);
    _logAnalytics(AnalyticsEventType.adRewardClaim, <String, Object?>{'placement': 'skip_timer'});
    await _persist();
    return true;
  }

  bool purchaseCoinPackSmallWithGems() {
    final cost = coinPackSmallGemCost;
    if (state.gems < cost) {
      return false;
    }
    final reward = totalCoinsPerSecond * MonetizationConfig.coinPackSmallSecondsWorth;
    _setStateSafely(
      _withUiEvent(
        state.copyWith(
          gems: state.gems - cost,
          coins: state.coins + reward,
          lifetimeCoinsEarned: state.lifetimeCoinsEarned + reward,
        ),
        event: 'gem_coin_pack',
      ),
    );
    _audioService.playCoin(enabled: state.settings.soundEnabled);
    _persist();
    _logAnalytics(AnalyticsEventType.gemSpend, <String, Object?>{
      'reason': 'coin_pack_small',
      'cost': cost,
    });
    return true;
  }

  bool purchaseBoostWithGems(String boostId) {
    final cfg = _boostManager.byId(boostId);
    if (cfg == null || cfg.gemCost <= 0 || state.gems < cfg.gemCost) {
      return false;
    }
    final now = DateTime.now().toUtc();
    final active = _boostManager.sanitize(state.activeBoosts, now);
    final nextActive = _boostManager.activate(existing: active, config: cfg, nowUtc: now);
    var nextState =
        _addTaskMetric(
          state.copyWith(
            gems: state.gems - cfg.gemCost,
            activeBoosts: nextActive,
          ),
          'boosts_activated',
          1,
        );
    _setStateSafely(
      _withUiEvent(
        nextState,
        event: 'gem_boost_buy',
      ),
    );
    _audioService.playUpgrade(enabled: state.settings.soundEnabled);
    _persist();
    _logAnalytics(AnalyticsEventType.gemSpend, <String, Object?>{
      'reason': 'boost_purchase',
      'boostId': boostId,
      'cost': cfg.gemCost,
    });
    _logAnalytics(AnalyticsEventType.boostActivation, <String, Object?>{
      'boostId': boostId,
      'source': 'store',
    });
    return true;
  }

  bool spendGemsToSkipStation(String stationId) {
    final cost = stationSkipGemCost;
    if (state.gems < cost) {
      return false;
    }
    final station = state.stations[stationId];
    if (station == null || !station.isUnlocked || !station.autoEnabled) {
      return false;
    }
    final config = configFor(stationId);
    final now = DateTime.now().toUtc();
    final boostSpeed = _boostManager.activeProductionSpeedMultiplier(state.activeBoosts, now);
    final speed = _stationSpeedMultiplier(stationId, station.level) * boostSpeed;
    final seconds = (config.productionTimeSeconds / speed).clamp(0.5, 999999.0);
    final updated = Map<String, StationState>.from(state.stations);
    updated[stationId] = station.copyWith(
      autoProgressSeconds: station.autoProgressSeconds + seconds,
      isProducing: true,
    );
    _setStateSafely(
      _withUiEvent(
        state.copyWith(
          gems: state.gems - cost,
          stations: updated,
        ),
        event: 'gem_skip_timer',
      ),
    );
    _audioService.playUpgrade(enabled: state.settings.soundEnabled);
    _persist();
    _logAnalytics(AnalyticsEventType.gemSpend, <String, Object?>{
      'reason': 'station_skip',
      'stationId': stationId,
      'cost': cost,
    });
    return true;
  }

  Future<void> clearQueue() async {
    _setStateSafely(
      state.copyWith(
        waitingCustomers: 0,
        waitingCustomerTypes: const <String>[],
        cafeOrders: const <CafeOrderState>[],
        stationQueues: const <String, List<StationTaskState>>{},
        cafeTables: _defaultCafeTables(),
      ),
    );
    await _persist();
  }

  Future<void> forceSave() async {
    await _persist();
  }

  Future<void> simulateOfflineHour() async {
    final now = DateTime.now().toUtc();
    final from = now.subtract(const Duration(hours: 1));
    final award = _offlineIncomeSystem.calculate(
      totalCoinsPerSecond: totalCoinsPerSecond,
      fromUtc: from,
      toUtc: now,
      offlineMultiplier: EconomyBalanceConfig.offlineMultiplier,
    );
    _setStateSafely(
      state.copyWith(
        coins: state.coins + award,
        lifetimeCoinsEarned: state.lifetimeCoinsEarned + award,
        lastOfflineIncome: award,
        offlineIncomeRewardedClaimed: award <= 0,
      ),
    );
    await _persist();
  }

  bool purchaseDecoration(String decorationId) {
    if (state.purchasedDecorationIds.contains(decorationId)) {
      return false;
    }
    final config = _decorationManager.byId(decorationId);
    final adjustedCost =
        (config.cost * _limitedEventManager.combinedDecorationCost(state.activeEvents))
            .toDouble();
    if (state.coins < adjustedCost) {
      return false;
    }
    final purchased = Set<String>.from(state.purchasedDecorationIds)..add(decorationId);
    var next = _applyExpansionStage(
      state.copyWith(
        coins: state.coins - adjustedCost,
        purchasedDecorationIds: purchased,
      ),
    );
    next = _addTaskMetric(next, 'decorations_bought', 1);
    _setStateSafely(_withUiEvent(next, event: 'decoration_bought'));
    _audioService.playUnlock(enabled: state.settings.soundEnabled);
    _persist();
    return true;
  }

  void tapStation(String stationId) {
    final station = state.stations[stationId];
    if (station == null || !station.isUnlocked) {
      selectStation(stationId);
      return;
    }

    if (stationId == 'cashier_counter') {
      final next = _takeReceptionOrder(state);
      _setStateSafely(_withUiEvent(next, event: 'order_taken', stationId: stationId));
      unawaited(_hapticsService.selectionClick(enabled: state.settings.hapticsEnabled));
      _audioService.playTap(enabled: state.settings.soundEnabled);
      _persist();
      return;
    }

    final hasStationTask = state.stationQueues[stationId]?.any((task) => !task.delivered) ?? false;
    if (hasStationTask) {
      final next = _completeStationTask(state, stationId);
      _setStateSafely(_withUiEvent(next, event: 'station_task_done', stationId: stationId));
      unawaited(_hapticsService.selectionClick(enabled: state.settings.hapticsEnabled));
      _audioService.playTap(enabled: state.settings.soundEnabled);
      _audioService.playCoin(enabled: state.settings.soundEnabled);
      _persist();
      return;
    }

    selectStation(stationId);
  }

  bool unlockStation(String stationId) {
    final station = state.stations[stationId];
    if (station == null || station.isUnlocked) {
      return false;
    }
    final config = configFor(stationId);
    if (state.coins < config.unlockCost) {
      return false;
    }
    final updated = Map<String, StationState>.from(state.stations);
    updated[stationId] = station.copyWith(isUnlocked: true, autoEnabled: true);
    var nextState = state.copyWith(
      coins: state.coins - config.unlockCost,
      stations: updated,
    );
    nextState = _awardXp(nextState, ProgressionBalanceConfig.xpPerStationUnlock);
    nextState = _applyExpansionStage(nextState);
    _setStateSafely(_withUiEvent(nextState, event: 'station_unlock', stationId: stationId));
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playUnlock(enabled: state.settings.soundEnabled);
    if (stationId == 'coffee_grinder') {
      unawaited(_completeTutorialStep('unlock_grinder'));
    }
    _persist();
    return true;
  }

  bool upgradeStation(String stationId) {
    final station = state.stations[stationId];
    if (station == null || !station.isUnlocked) {
      return false;
    }
    if (station.level >= 100) {
      return false;
    }
    final config = configFor(stationId);
    final cost = _economy.upgradeCost(config, station.level);
    if (state.coins < cost) {
      return false;
    }
    final updated = Map<String, StationState>.from(state.stations);
    updated[stationId] = station.copyWith(level: (station.level + 1).clamp(1, 100).toInt());
    var nextState = state.copyWith(coins: state.coins - cost, stations: updated);
    nextState = _awardXp(nextState, ProgressionBalanceConfig.xpPerStationUpgrade);
    nextState = _addTaskMetric(nextState, 'station_upgrades', 1);
    nextState = _applyExpansionStage(nextState);
    _setStateSafely(_withUiEvent(nextState, event: 'station_upgrade', stationId: stationId));
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playUpgrade(enabled: state.settings.soundEnabled);
    _logAnalytics(AnalyticsEventType.stationUpgrade, <String, Object?>{
      'stationId': stationId,
      'level': station.level + 1,
    });
    if (stationId == 'espresso_machine') {
      unawaited(_completeTutorialStep('upgrade_espresso'));
    }
    _persist();
    return true;
  }

  bool hireWorker(String workerId) {
    final worker = _workerManager.byId(workerId);
    if (worker == null || isWorkerHired(workerId)) {
      return false;
    }
    final station = state.stations[worker.assignedStationId];
    if (station == null || !station.isUnlocked || state.coins < worker.hireCost) {
      return false;
    }
    final nextWorkers = Set<String>.from(state.workersHired)..add(workerId);
    final nextStations = Map<String, StationState>.from(state.stations);
    nextStations[worker.assignedStationId] = station.copyWith(autoEnabled: true);
    final nextWorkerLevels = Map<String, int>.from(state.workerLevels)
      ..putIfAbsent(workerId, () => 1);
    var nextState = state.copyWith(
      coins: state.coins - worker.hireCost,
      workersHired: nextWorkers,
      workerLevels: nextWorkerLevels,
      stations: nextStations,
    );
    nextState = _awardXp(nextState, ProgressionBalanceConfig.xpPerWorkerHire);
    _setStateSafely(
      _withUiEvent(
        nextState,
        event: 'worker_hired',
        stationId: worker.assignedStationId,
      ),
    );
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playUnlock(enabled: state.settings.soundEnabled);
    _logAnalytics(AnalyticsEventType.workerHire, <String, Object?>{
      'workerId': workerId,
      'stationId': worker.assignedStationId,
    });
    unawaited(_completeTutorialStep('hire_worker'));
    _persist();
    return true;
  }

  bool upgradeWorker(String workerId) {
    if (!isWorkerHired(workerId)) {
      return false;
    }
    final worker = _workerManager.byId(workerId);
    if (worker == null) {
      return false;
    }
    final level = workerLevel(workerId);
    if (level >= 2) {
      return false;
    }
    final cost = _workerManager.upgradeCost(worker, level);
    if (state.coins < cost) {
      return false;
    }
    final nextWorkerLevels = Map<String, int>.from(state.workerLevels)
      ..[workerId] = level + 1;
    var nextState = state.copyWith(
      coins: state.coins - cost,
      workerLevels: nextWorkerLevels,
    );
    nextState = _awardXp(nextState, ProgressionBalanceConfig.xpPerWorkerUpgrade);
    _setStateSafely(_withUiEvent(nextState, event: 'worker_upgrade'));
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playUpgrade(enabled: state.settings.soundEnabled);
    _persist();
    return true;
  }

  bool purchaseManager(String managerId) {
    if (state.purchasedManagerIds.contains(managerId)) {
      return false;
    }
    final cfg = _managerUpgradeManager.byId(managerId);
    if (cfg == null || !_managerUpgradeManager.isUnlocked(state, cfg)) {
      return false;
    }
    if (state.coins < cfg.cost) {
      return false;
    }
    final nextManagers = Set<String>.from(state.purchasedManagerIds)..add(managerId);
    final nextState = state.copyWith(
      coins: state.coins - cfg.cost,
      purchasedManagerIds: nextManagers,
    );
    _setStateSafely(_withUiEvent(nextState, event: 'manager_bought'));
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playUpgrade(enabled: state.settings.soundEnabled);
    _persist();
    return true;
  }

  bool purchasePermanentUpgrade(String upgradeId) {
    if (state.purchasedPermanentUpgradeIds.contains(upgradeId)) {
      return false;
    }
    final cfg = _permanentUpgradeManager.byId(upgradeId);
    if (cfg == null || state.prestigePoints < cfg.costPrestigePoints) {
      return false;
    }
    final nextPurchased = Set<String>.from(state.purchasedPermanentUpgradeIds)..add(upgradeId);
    final nextState = state.copyWith(
      prestigePoints: state.prestigePoints - cfg.costPrestigePoints,
      purchasedPermanentUpgradeIds: nextPurchased,
    );
    _setStateSafely(_withUiEvent(nextState, event: 'permanent_upgrade_bought'));
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playUpgrade(enabled: state.settings.soundEnabled);
    _persist();
    return true;
  }

  bool claimPrestigeAchievement(String achievementId) {
    if (state.claimedPrestigeAchievementIds.contains(achievementId)) {
      return false;
    }
    final list = _prestigeAchievementManager.buildAchievements(state);
    PrestigeAchievementState? found;
    for (final item in list) {
      if (item.config.id == achievementId) {
        found = item;
        break;
      }
    }
    if (found == null || !found.completed) {
      return false;
    }

    final nextClaimed = Set<String>.from(state.claimedPrestigeAchievementIds)
      ..add(achievementId);
    var nextState = state.copyWith(
      coins: state.coins + found.config.rewardCoins,
      lifetimeCoinsEarned: state.lifetimeCoinsEarned + found.config.rewardCoins,
      prestigePoints: state.prestigePoints + found.config.rewardPrestigePoints,
      claimedPrestigeAchievementIds: nextClaimed,
    );
    nextState = _awardXp(nextState, found.config.rewardXp);
    nextState = _applyExpansionStage(nextState);
    _setStateSafely(_withUiEvent(nextState, event: 'prestige_achievement_claimed'));
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playCoin(enabled: state.settings.soundEnabled);
    _persist();
    return true;
  }

  Future<bool> performPrestigeReset() async {
    final award = potentialPrestigePoints;
    if (award <= 0) {
      return false;
    }

    final now = DateTime.now().toUtc();
    final runReset = _buildPrestigeRunResetState(
      nowUtc: now,
      awardedPrestigePoints: award,
    );
    final runResetWithTasks = _addTaskMetric(runReset, 'prestige_count', 1);
    _setStateSafely(_withUiEvent(runResetWithTasks, event: 'prestige_reset'));
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playPrestige(enabled: state.settings.soundEnabled);
    _logAnalytics(AnalyticsEventType.prestige, <String, Object?>{'awarded': award});
    unawaited(_completeTutorialStep('prestige_intro'));
    await _persist();
    return true;
  }

  bool claimAchievement(String achievementId) {
    if (state.claimedAchievementIds.contains(achievementId)) {
      return false;
    }
    final list = _achievementManager.buildAchievements(state);
    AchievementState? found;
    for (final item in list) {
      if (item.config.id == achievementId) {
        found = item;
        break;
      }
    }
    if (found == null || !found.completed) {
      return false;
    }
    final nextClaimed = Set<String>.from(state.claimedAchievementIds)..add(achievementId);
    var nextState = state.copyWith(
      coins: state.coins + found.config.rewardCoins,
      lifetimeCoinsEarned: state.lifetimeCoinsEarned + found.config.rewardCoins,
      claimedAchievementIds: nextClaimed,
    );
    nextState = _awardXp(nextState, found.config.rewardXp);
    nextState = _applyExpansionStage(nextState);
    _setStateSafely(_withUiEvent(nextState, event: 'achievement_claimed'));
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playCoin(enabled: state.settings.soundEnabled);
    _logAnalytics(AnalyticsEventType.achievementCompletion, <String, Object?>{
      'achievementId': achievementId,
    });
    _persist();
    return true;
  }

  bool claimMilestone(String milestoneId) {
    final all = _milestoneManager.buildMilestones(state);
    MilestoneState? milestone;
    for (final item in all) {
      if (item.config.id == milestoneId) {
        milestone = item;
        break;
      }
    }
    if (milestone == null || !milestone.claimable) {
      return false;
    }
    final rewardMilestone = milestone;
    final claimed = Set<String>.from(state.claimedMilestoneIds)..add(milestoneId);
    var nextState = state.copyWith(
      coins: state.coins + rewardMilestone.config.rewardCoins,
      lifetimeCoinsEarned:
          state.lifetimeCoinsEarned + rewardMilestone.config.rewardCoins,
      claimedMilestoneIds: claimed,
    );
    nextState = _awardXp(nextState, rewardMilestone.config.rewardXp);
    nextState = _addTaskMetric(nextState, 'milestones_claimed', 1);
    nextState = _applyExpansionStage(nextState);
    _setStateSafely(_withUiEvent(nextState, event: 'milestone_claimed'));
    unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
    _audioService.playMilestoneComplete(enabled: state.settings.soundEnabled);
    _logAnalytics(AnalyticsEventType.milestoneCompletion, <String, Object?>{
      'milestoneId': milestoneId,
    });
    _persist();
    return true;
  }

  void toggleAuto(String stationId, bool enabled) {
    final station = state.stations[stationId];
    if (station == null || !station.isUnlocked) {
      return;
    }
    final worker = _workerManager.forStation(stationId);
    final workerNotHired = worker != null && !isWorkerHired(worker.id);
    if (enabled && workerNotHired) {
      return;
    }

    final updated = Map<String, StationState>.from(state.stations);
    updated[stationId] = station.copyWith(autoEnabled: enabled);
    _setStateSafely(
      _withUiEvent(
        state.copyWith(stations: updated),
        event: enabled ? 'auto_enabled' : 'auto_disabled',
        stationId: stationId,
      ),
    );
    if (enabled) {
      unawaited(_completeTutorialStep('enable_auto'));
    }
    _persist();
  }

  void tick(double dtSeconds) {
    if (!_loaded || state.stations.isEmpty) {
      return;
    }
    _rollTaskWindows(todayKey: _dateKey(DateTime.now().toUtc()));
    final nowUtc = DateTime.now().toUtc();
    final activeBoosts = _boostManager.sanitize(state.activeBoosts, nowUtc);
    final boostSpeedMultiplier = _boostManager.activeProductionSpeedMultiplier(
      activeBoosts,
      nowUtc,
    );
    final boostSpawnMultiplier = _boostManager.activeSpawnRateMultiplier(
      activeBoosts,
      nowUtc,
    );

    var coins = state.coins;
    var lifetimeCoins = state.lifetimeCoinsEarned;
    var coffeeCups = state.coffeeCups;
    var lifetimeCups = state.lifetimeCupsProduced;
    var servedCustomers = state.servedCustomers;
    var lifetimeServed = state.lifetimeCustomersServed;
    var queueTypes = List<String>.from(state.waitingCustomerTypes);
    var cafeOrders = List<CafeOrderState>.from(state.cafeOrders);
    var stationQueues = _cloneStationQueues(state.stationQueues);
    var cafeTables = List<CafeTableState>.from(state.cafeTables);
    var servedByType = Map<String, int>.from(state.servedByCustomerType);
    var tipsEarned = state.tipsEarned;
    var tipsReceived = state.tipsReceived;
    var satisfiedOrders = state.satisfiedOrders;
    var failedOrders = state.failedOrders;
    var spawnBoostRemainingSeconds = state.spawnBoostRemainingSeconds;
    var spawnBoostMultiplier = state.spawnBoostMultiplier;

    final spawnBoost = state.spawnBoostRemainingSeconds > 0
        ? state.spawnBoostMultiplier
        : 1.0;
    final spawnInterval = EconomyBalanceConfig.customerSpawnIntervalSeconds /
        (currentExpansion.customerSpawnRateMultiplier *
            _limitedEventManager.combinedCustomerSpawnRate(state.activeEvents) *
            spawnBoost *
            boostSpawnMultiplier *
            _decorationManager.spawnRateMultiplier(state.purchasedDecorationIds) *
            _managerUpgradeManager.customerSpawnRateMultiplier(state) *
            _permanentUpgradeManager.customerSpawnRateMultiplier(
              state.purchasedPermanentUpgradeIds,
            ));
    var spawnProgress = state.customerSpawnProgressSeconds + dtSeconds;

    if (spawnProgress >= spawnInterval) {
      final spawnCycles = (spawnProgress / spawnInterval).floor();
      spawnProgress = spawnProgress % spawnInterval;
      final maxQueue = _maxQueueCustomersForState(state);
      for (var i = 0; i < spawnCycles; i++) {
        if (queueTypes.length >= maxQueue) {
          break;
        }
        queueTypes.add(_pickSpawnType(state, _random.nextDouble()));
      }
    }

    var ordersAdded = 0;
    while (queueTypes.isNotEmpty && _hasOpenCafeSeat(cafeTables)) {
      final next = _takeReceptionOrderFromParts(
        queueTypes: queueTypes,
        orders: cafeOrders,
        stationQueues: stationQueues,
        tables: cafeTables,
        nextSerial: state.nextOrderSerial + ordersAdded,
      );
      if (next.ordersAdded == 0) {
        break;
      }
      queueTypes = next.queueTypes;
      cafeOrders = next.orders;
      stationQueues = next.stationQueues;
      cafeTables = next.tables;
      ordersAdded += next.ordersAdded;
    }

    var nextOrderSerial = state.nextOrderSerial + ordersAdded;
    final orderTick = _tickCafeOrders(
      orders: cafeOrders,
      stationQueues: stationQueues,
      tables: cafeTables,
      dtSeconds: dtSeconds,
      coins: coins,
      lifetimeCoins: lifetimeCoins,
      servedCustomers: servedCustomers,
      lifetimeServed: lifetimeServed,
      servedByType: servedByType,
      tipsEarned: tipsEarned,
      tipsReceived: tipsReceived,
      satisfiedOrders: satisfiedOrders,
      failedOrders: failedOrders,
    );
    cafeOrders = orderTick.orders;
    stationQueues = orderTick.stationQueues;
    cafeTables = orderTick.tables;
    coins = orderTick.coins;
    lifetimeCoins = orderTick.lifetimeCoins;
    servedCustomers = orderTick.servedCustomers;
    lifetimeServed = orderTick.lifetimeServed;
    servedByType = orderTick.servedByType;
    tipsEarned = orderTick.tipsEarned;
    tipsReceived = orderTick.tipsReceived;
    satisfiedOrders = orderTick.satisfiedOrders;
    failedOrders = orderTick.failedOrders;

    final updatedStations = <String, StationState>{};
    for (final entry in state.stations.entries) {
      final stationId = entry.key;
      final station = entry.value;
      final taskQueue = stationQueues[stationId] ?? const <StationTaskState>[];
      if (taskQueue.isNotEmpty && station.isUnlocked) {
        final config = configFor(stationId);
        final worker = _workerManager.forStation(stationId);
        final workerBoost = (worker != null && isWorkerHired(worker.id))
            ? _workerManager.efficiencyForLevel(worker, workerLevel(worker.id))
            : 0.0;
        final permanentWorkerMultiplier = _permanentUpgradeManager.workerEfficiencyMultiplier(
          state.purchasedPermanentUpgradeIds,
        );
        final rateBoost =
            1 + (workerBoost * permanentWorkerMultiplier) *
                EconomyBalanceConfig.workerAutomationRateMultiplier;
        final activeCookCount = cookCountForStation(stationId).clamp(1, 3).toInt();
        final updatedQueue = List<StationTaskState>.from(taskQueue);
        var completedAny = false;
        var leadingProgress = 0.0;
        for (var i = 0; i < updatedQueue.length && i < activeCookCount; i++) {
          final taskSeconds = (config.productionTimeSeconds *
                  _taskBatchQuantity(cafeOrders, updatedQueue[i]).clamp(1, 9)) /
              (rateBoost * _stationSpeedMultiplier(stationId, station.level) * boostSpeedMultiplier);
          final progress = updatedQueue[i].progressSeconds + dtSeconds;
          if (i == 0) {
            leadingProgress = taskSeconds <= 0 ? 0 : (progress / taskSeconds).clamp(0.0, 1.0).toDouble();
          }
          updatedQueue[i] = updatedQueue[i].copyWith(progressSeconds: progress);
        }
        stationQueues[stationId] = updatedQueue;
        while ((stationQueues[stationId] ?? const <StationTaskState>[]).isNotEmpty) {
          final first = stationQueues[stationId]!.first;
          final firstSeconds = (config.productionTimeSeconds *
                  _taskBatchQuantity(cafeOrders, first).clamp(1, 9)) /
              (rateBoost * _stationSpeedMultiplier(stationId, station.level) * boostSpeedMultiplier);
          if (first.progressSeconds < firstSeconds) {
            break;
          }
          completedAny = true;
          final completed = _completeStationTaskFromParts(
            stationId: stationId,
            orders: cafeOrders,
            stationQueues: stationQueues,
            tables: cafeTables,
            coins: coins,
            lifetimeCoins: lifetimeCoins,
            servedCustomers: servedCustomers,
            lifetimeServed: lifetimeServed,
            servedByType: servedByType,
            tipsEarned: tipsEarned,
            tipsReceived: tipsReceived,
            satisfiedOrders: satisfiedOrders,
            failedOrders: failedOrders,
          );
          cafeOrders = completed.orders;
          stationQueues = completed.stationQueues;
          cafeTables = completed.tables;
          coins = completed.coins;
          lifetimeCoins = completed.lifetimeCoins;
          servedCustomers = completed.servedCustomers;
          lifetimeServed = completed.lifetimeServed;
          servedByType = completed.servedByType;
          tipsEarned = completed.tipsEarned;
          tipsReceived = completed.tipsReceived;
          satisfiedOrders = completed.satisfiedOrders;
          failedOrders = completed.failedOrders;
        }
        if (completedAny && (stationQueues[stationId] ?? const <StationTaskState>[]).isEmpty) {
          updatedStations[stationId] = station.copyWith(
            autoProgressSeconds: 0,
            isProducing: false,
            productionProgress: 0,
            clearBlockedReason: true,
          );
        } else {
          updatedStations[stationId] = station.copyWith(
            autoProgressSeconds: (stationQueues[stationId] ?? const <StationTaskState>[]).isEmpty
                ? 0
                : stationQueues[stationId]!.first.progressSeconds,
            isProducing: true,
            productionProgress: leadingProgress,
            clearBlockedReason: true,
          );
        }
        continue;
      }
      if (!station.isUnlocked || !station.autoEnabled) {
        updatedStations[stationId] = station.copyWith(
          isProducing: false,
          productionProgress: 0,
          clearBlockedReason: true,
        );
        continue;
      }

      updatedStations[stationId] = station.copyWith(
        autoProgressSeconds: 0,
        isProducing: false,
        productionProgress: 0,
        blockedReason: 'No orders',
      );
      continue;
    }

    var nextState = state.copyWith(
      coins: coins,
      lifetimeCoinsEarned: lifetimeCoins,
      lifetimeCustomersServed: lifetimeServed,
      lifetimeCupsProduced: lifetimeCups,
      resources: state.resources.copyWith(
        coffeeCups: coffeeCups,
        servedCustomers: servedCustomers,
      ),
      waitingCustomers: queueTypes.length,
      waitingCustomerTypes: queueTypes,
      cafeOrders: cafeOrders,
      stationQueues: stationQueues,
      cafeTables: cafeTables,
      servedByCustomerType: servedByType,
      tipsEarned: tipsEarned,
      tipsReceived: tipsReceived,
      satisfiedOrders: satisfiedOrders,
      failedOrders: failedOrders,
      nextOrderSerial: nextOrderSerial,
      customerSpawnProgressSeconds: spawnProgress,
      spawnBoostRemainingSeconds: spawnBoostRemainingSeconds > 0
          ? (spawnBoostRemainingSeconds - dtSeconds).clamp(0.0, 120.0)
          : 0.0,
      spawnBoostMultiplier: spawnBoostRemainingSeconds > dtSeconds
          ? spawnBoostMultiplier
          : 1.0,
      stations: updatedStations,
      activeBoosts: activeBoosts,
    );
    final servedDelta = lifetimeServed - state.lifetimeCustomersServed;
    final coinsDelta = (lifetimeCoins - state.lifetimeCoinsEarned).floor();
    if (servedDelta > 0) {
      nextState = _awardXp(
        nextState,
        ProgressionBalanceConfig.xpPerCustomerServed * servedDelta,
      );
    }
    nextState = _addTaskMetric(nextState, 'customers_served', servedDelta);
    nextState = _addTaskMetric(nextState, 'coins_earned', coinsDelta);
    nextState = _applyExpansionStage(nextState);
    _setStateSafely(nextState);
  }

  Future<void> resetRunProgress() async {
    final now = DateTime.now().toUtc();
    final runReset = _buildPrestigeRunResetState(
      nowUtc: now,
      awardedPrestigePoints: 0,
    ).copyWith(
      prestigePoints: state.prestigePoints,
      lifetimePrestigePoints: state.lifetimePrestigePoints,
      prestigeCount: state.prestigeCount,
      purchasedPermanentUpgradeIds: state.purchasedPermanentUpgradeIds,
      completedAchievementIds: state.completedAchievementIds,
      claimedAchievementIds: state.claimedAchievementIds,
      completedPrestigeAchievementIds: state.completedPrestigeAchievementIds,
      claimedPrestigeAchievementIds: state.claimedPrestigeAchievementIds,
      settings: state.settings,
      tutorial: state.tutorial,
      dailyReward: state.dailyReward,
      loginStreak: state.loginStreak,
      dailyTasks: state.dailyTasks,
      weeklyTasks: state.weeklyTasks,
      dailyTaskDateKey: state.dailyTaskDateKey,
      weeklyTaskDateKey: state.weeklyTaskDateKey,
      activeEvents: state.activeEvents,
      selectedThemeId: state.selectedThemeId,
      eventBeans: state.eventBeans,
      notificationPreferences: state.notificationPreferences,
      saveVersion: GameSaveData.currentSaveVersion,
      lastSavedAtUtcMillis: now.millisecondsSinceEpoch,
    );
    _setStateSafely(runReset);
    await _persist();
  }

  Future<void> resetProgress() async {
    await _saveService.clear();
    await _settingsService.clearAll();
    _setStateSafely(_initialState(DateTime.now().toUtc()));
    await _persist();
  }

  Map<String, List<StationTaskState>> _cloneStationQueues(
    Map<String, List<StationTaskState>> source,
  ) {
    return source.map((key, value) => MapEntry(key, List<StationTaskState>.from(value)));
  }

  GameState _takeReceptionOrder(GameState source) {
    final result = _takeReceptionOrderFromParts(
      queueTypes: List<String>.from(source.waitingCustomerTypes),
      orders: List<CafeOrderState>.from(source.cafeOrders),
      stationQueues: _cloneStationQueues(source.stationQueues),
      tables: List<CafeTableState>.from(source.cafeTables),
      nextSerial: source.nextOrderSerial,
    );
    return source.copyWith(
      waitingCustomers: result.queueTypes.length,
      waitingCustomerTypes: result.queueTypes,
      cafeOrders: result.orders,
      stationQueues: result.stationQueues,
      cafeTables: result.tables,
      nextOrderSerial: source.nextOrderSerial + result.ordersAdded,
    );
  }

  _ReceptionOrderResult _takeReceptionOrderFromParts({
    required List<String> queueTypes,
    required List<CafeOrderState> orders,
    required Map<String, List<StationTaskState>> stationQueues,
    required List<CafeTableState> tables,
    required int nextSerial,
  }) {
    if (queueTypes.isEmpty) {
      return _ReceptionOrderResult(queueTypes, orders, stationQueues, tables, 0);
    }
    final customerTypeId = queueTypes.removeAt(0);
    final typeCfg = _customerTypeManager.byId(customerTypeId);
    final catalog = _availableOrderItems(state.copyWith(
      waitingCustomerTypes: queueTypes,
      cafeOrders: orders,
      stationQueues: stationQueues,
      cafeTables: tables,
    ));
    if (catalog.isEmpty) {
      queueTypes.insert(0, customerTypeId);
      return _ReceptionOrderResult(queueTypes, orders, stationQueues, tables, 0);
    }
    final itemCount = 1 + (nextSerial % 3);
    final requested = <CafeOrderItemState>[];
    final item = catalog[nextSerial % catalog.length];
    for (var i = 0; i < itemCount; i++) {
      requested.add(
        CafeOrderItemState(
          itemId: '${item.id}_$i',
          stationId: item.stationId,
          label: item.label,
          icon: item.icon,
        ),
      );
    }
    final orderId = 'order_$nextSerial';
    final customerId = 'customer_$nextSerial';
    final tableIndex = tables.indexWhere((table) => table.isUnlocked && !table.isOccupied);
    final tableId = tableIndex >= 0 ? tables[tableIndex].tableId : null;
    if (tableIndex >= 0) {
      tables[tableIndex] = tables[tableIndex].copyWith(customerId: customerId);
    }
    final value = requested.fold<double>(
      0,
      (sum, item) => sum + _orderItemValue(item.stationId) * typeCfg.rewardMultiplier,
    );
    final patience = (70 + requested.length * 18) * typeCfg.patienceMultiplier;
    final tipChance = (0.16 + requested.length * 0.035 + (typeCfg.rewardMultiplier - 1) * 0.08)
        .clamp(0.05, 0.62)
        .toDouble();
    final order = CafeOrderState(
      orderId: orderId,
      customerId: customerId,
      customerTypeId: customerTypeId,
      requestedItems: requested,
      orderValue: value,
      tipChance: tipChance,
      patienceSeconds: patience,
      maxPatienceSeconds: patience,
      phase: CafeOrderPhase.seated,
      tableId: tableId,
    );
    orders.add(order);
    final task = StationTaskState(
      taskId: '${orderId}_${item.id}_batch',
      orderId: orderId,
      customerId: customerId,
      stationId: item.stationId,
      itemId: item.id,
      itemLabel: item.label,
      itemIcon: item.icon,
    );
    stationQueues.putIfAbsent(item.stationId, () => <StationTaskState>[]).add(task);
    return _ReceptionOrderResult(queueTypes, orders, stationQueues, tables, 1);
  }

  GameState _completeStationTask(GameState source, String stationId) {
    final result = _completeStationTaskFromParts(
      stationId: stationId,
      orders: List<CafeOrderState>.from(source.cafeOrders),
      stationQueues: _cloneStationQueues(source.stationQueues),
      tables: List<CafeTableState>.from(source.cafeTables),
      coins: source.coins,
      lifetimeCoins: source.lifetimeCoinsEarned,
      servedCustomers: source.servedCustomers,
      lifetimeServed: source.lifetimeCustomersServed,
      servedByType: Map<String, int>.from(source.servedByCustomerType),
      tipsEarned: source.tipsEarned,
      tipsReceived: source.tipsReceived,
      satisfiedOrders: source.satisfiedOrders,
      failedOrders: source.failedOrders,
    );
    var next = source.copyWith(
      coins: result.coins,
      lifetimeCoinsEarned: result.lifetimeCoins,
      lifetimeCustomersServed: result.lifetimeServed,
      resources: source.resources.copyWith(servedCustomers: result.servedCustomers),
      cafeOrders: result.orders,
      stationQueues: result.stationQueues,
      cafeTables: result.tables,
      servedByCustomerType: result.servedByType,
      tipsEarned: result.tipsEarned,
      tipsReceived: result.tipsReceived,
      satisfiedOrders: result.satisfiedOrders,
      failedOrders: result.failedOrders,
    );
    final servedDelta = result.lifetimeServed - source.lifetimeCustomersServed;
    if (servedDelta > 0) {
      next = _awardXp(next, ProgressionBalanceConfig.xpPerCustomerServed * servedDelta);
      next = _addTaskMetric(next, 'customers_served', servedDelta);
      next = _addTaskMetric(next, 'coins_earned', (result.lifetimeCoins - source.lifetimeCoinsEarned).floor());
      next = _applyExpansionStage(next);
    }
    return next;
  }

  _OrderProcessResult _tickCafeOrders({
    required List<CafeOrderState> orders,
    required Map<String, List<StationTaskState>> stationQueues,
    required List<CafeTableState> tables,
    required double dtSeconds,
    required double coins,
    required double lifetimeCoins,
    required int servedCustomers,
    required int lifetimeServed,
    required Map<String, int> servedByType,
    required double tipsEarned,
    required int tipsReceived,
    required int satisfiedOrders,
    required int failedOrders,
  }) {
    final kept = <CafeOrderState>[];
    for (final order in orders) {
      final patience = (order.patienceSeconds - dtSeconds)
          .clamp(0.0, order.maxPatienceSeconds)
          .toDouble();
      final aged = order.copyWith(
        patienceSeconds: patience,
        elapsedSeconds: order.elapsedSeconds + dtSeconds,
      );
      if (patience <= 0 && !order.isComplete) {
        failedOrders += 1;
        stationQueues = _removeOrderTasks(stationQueues, order.orderId);
        tables = _freeTable(tables, order.customerId);
        continue;
      }
      kept.add(aged);
    }
    return _OrderProcessResult(
      orders: kept,
      stationQueues: stationQueues,
      tables: tables,
      coins: coins,
      lifetimeCoins: lifetimeCoins,
      servedCustomers: servedCustomers,
      lifetimeServed: lifetimeServed,
      servedByType: servedByType,
      tipsEarned: tipsEarned,
      tipsReceived: tipsReceived,
      satisfiedOrders: satisfiedOrders,
      failedOrders: failedOrders,
    );
  }

  _OrderProcessResult _completeStationTaskFromParts({
    required String stationId,
    required List<CafeOrderState> orders,
    required Map<String, List<StationTaskState>> stationQueues,
    required List<CafeTableState> tables,
    required double coins,
    required double lifetimeCoins,
    required int servedCustomers,
    required int lifetimeServed,
    required Map<String, int> servedByType,
    required double tipsEarned,
    required int tipsReceived,
    required int satisfiedOrders,
    required int failedOrders,
  }) {
    final queue = List<StationTaskState>.from(stationQueues[stationId] ?? const <StationTaskState>[]);
    if (queue.isEmpty) {
      return _OrderProcessResult(
        orders: orders,
        stationQueues: stationQueues,
        tables: tables,
        coins: coins,
        lifetimeCoins: lifetimeCoins,
        servedCustomers: servedCustomers,
        lifetimeServed: lifetimeServed,
        servedByType: servedByType,
        tipsEarned: tipsEarned,
        tipsReceived: tipsReceived,
        satisfiedOrders: satisfiedOrders,
        failedOrders: failedOrders,
      );
    }
    final task = queue.removeAt(0).copyWith(produced: true, delivered: true, progressSeconds: 0);
    stationQueues[stationId] = queue;
    final orderIndex = orders.indexWhere((order) => order.orderId == task.orderId);
    if (orderIndex < 0) {
      return _OrderProcessResult(
        orders: orders,
        stationQueues: stationQueues,
        tables: tables,
        coins: coins,
        lifetimeCoins: lifetimeCoins,
        servedCustomers: servedCustomers,
        lifetimeServed: lifetimeServed,
        servedByType: servedByType,
        tipsEarned: tipsEarned,
        tipsReceived: tipsReceived,
        satisfiedOrders: satisfiedOrders,
        failedOrders: failedOrders,
      );
    }
    final order = orders[orderIndex];
    final deliveredItems = <CafeOrderItemState>[
      for (final item in order.requestedItems)
        item.stationId == task.stationId ? item.copyWith(produced: true, delivered: true) : item,
    ];
    var updatedOrder = order.copyWith(requestedItems: deliveredItems);
    if (updatedOrder.isComplete) {
      final speedRatio = (updatedOrder.patienceSeconds / updatedOrder.maxPatienceSeconds)
          .clamp(0.0, 1.0)
          .toDouble();
      final effectiveTipChance = (updatedOrder.tipChance * (0.45 + speedRatio * 0.9))
          .clamp(0.0, 0.85)
          .toDouble();
      final tip = _random.nextDouble() <= effectiveTipChance
          ? (updatedOrder.orderValue * (0.08 + speedRatio * 0.12)).roundToDouble()
          : 0.0;
      final payout = updatedOrder.orderValue + tip;
      coins += payout;
      lifetimeCoins += payout;
      servedCustomers += 1;
      lifetimeServed += 1;
      tipsEarned += tip;
      tipsReceived += tip > 0 ? 1 : 0;
      satisfiedOrders += 1;
      servedByType[updatedOrder.customerTypeId] = (servedByType[updatedOrder.customerTypeId] ?? 0) + 1;
      tables = _freeTable(tables, updatedOrder.customerId);
      orders.removeAt(orderIndex);
    } else {
      orders[orderIndex] = updatedOrder;
    }
    return _OrderProcessResult(
      orders: orders,
      stationQueues: stationQueues,
      tables: tables,
      coins: coins,
      lifetimeCoins: lifetimeCoins,
      servedCustomers: servedCustomers,
      lifetimeServed: lifetimeServed,
      servedByType: servedByType,
      tipsEarned: tipsEarned,
      tipsReceived: tipsReceived,
      satisfiedOrders: satisfiedOrders,
      failedOrders: failedOrders,
    );
  }

  Map<String, List<StationTaskState>> _removeOrderTasks(
    Map<String, List<StationTaskState>> stationQueues,
    String orderId,
  ) {
    return stationQueues.map(
      (stationId, tasks) => MapEntry(
        stationId,
        tasks.where((task) => task.orderId != orderId).toList(growable: false),
      ),
    );
  }

  List<CafeTableState> _freeTable(List<CafeTableState> tables, String customerId) {
    return <CafeTableState>[
      for (final table in tables)
        table.customerId == customerId ? table.copyWith(clearCustomerId: true) : table,
    ];
  }

  bool _hasOpenCafeSeat(List<CafeTableState> tables) {
    return tables.any((table) => table.isUnlocked && !table.isOccupied);
  }

  int _taskBatchQuantity(List<CafeOrderState> orders, StationTaskState task) {
    final orderIndex = orders.indexWhere((order) => order.orderId == task.orderId);
    if (orderIndex < 0) {
      return 1;
    }
    return orders[orderIndex]
        .requestedItems
        .where((item) => item.stationId == task.stationId)
        .length
        .clamp(1, 9)
        .toInt();
  }

  List<_OrderMenuItem> _availableOrderItems(GameState source) {
    final items = <_OrderMenuItem>[];
    void addIfUnlocked(String stationId, String id, String label, String icon) {
      if (source.stations[stationId]?.isUnlocked ?? false) {
        items.add(_OrderMenuItem(id, stationId, label, icon));
      }
    }

    addIfUnlocked('espresso_machine', 'coffee', 'Coffee', '☕');
    addIfUnlocked('coffee_grinder', 'burger', 'Burger', '🍔');
    addIfUnlocked('pastry_display', 'cake', 'Cake', '🍰');
    return items;
  }

  double _orderItemValue(String stationId) {
    final station = state.stations[stationId];
    final config = configFor(stationId);
    final level = station?.level ?? 1;
    return _economy.profitPerTap(config, station ?? StationState(
      stationId: stationId,
      level: level,
      isUnlocked: true,
      autoEnabled: true,
    )) *
        _stationBonusManager.profitMultiplier(stationId, level) *
        _globalIncomeMultiplier();
  }

  String _pickSpawnType(GameState gameState, double seed) {
    final picked = _customerTypeManager.pickType(
      seed,
      eligibility: (cfg) {
        final requiredStationId = cfg.requiresStationId;
        if (requiredStationId == null) {
          return true;
        }
        return gameState.stations[requiredStationId]?.isUnlocked ?? false;
      },
    );
    final vipBoost = _limitedEventManager.combinedVipChance(state.activeEvents);
    if (vipBoost > 1 && picked == 'regular' && _random.nextDouble() < (0.1 * (vipBoost - 1)).clamp(0, 0.6)) {
      return 'vip';
    }
    return picked;
  }

  double _globalIncomeMultiplier({DateTime? nowUtc}) {
    final now = nowUtc ?? DateTime.now().toUtc();
    final boostIncome = _boostManager.activeIncomeMultiplier(state.activeBoosts, now);
    return currentExpansion.incomeMultiplier *
        _decorationManager.incomeMultiplier(state.purchasedDecorationIds) *
        _managerUpgradeManager.globalIncomeMultiplier(state) *
        currentPrestigeMultiplier *
        boostIncome;
  }

  double _stationSpeedMultiplier(String stationId, int level) {
    return _stationBonusManager.productionSpeedMultiplier(stationId, level) *
        _managerUpgradeManager.stationSpeedMultiplier(state, stationId) *
        _permanentUpgradeManager.stationSpeedMultiplier(state.purchasedPermanentUpgradeIds);
  }

  double _calculateOfflineAward(GameState gameState, DateTime nowUtc) {
    var totalCps = 0.0;
    final expansion = _expansionManager.byId(gameState.expansionStageId);
    final decorationIncome =
        _decorationManager.incomeMultiplier(gameState.purchasedDecorationIds);
    final managerIncome = _managerUpgradeManager.globalIncomeMultiplier(gameState);
    final prestigeIncome = PrestigeBalanceConfig.multiplierFromPoints(
      gameState.prestigePoints,
    );
    final permanentStationSpeed = _permanentUpgradeManager.stationSpeedMultiplier(
      gameState.purchasedPermanentUpgradeIds,
    );
    final permanentWorkerEfficiency = _permanentUpgradeManager.workerEfficiencyMultiplier(
      gameState.purchasedPermanentUpgradeIds,
    );
    final activeBoosts = _boostManager.sanitize(gameState.activeBoosts, nowUtc);
    final incomeBoost = _boostManager.activeIncomeMultiplier(activeBoosts, nowUtc);
    final speedBoost = _boostManager.activeProductionSpeedMultiplier(activeBoosts, nowUtc);
    for (final config in stationConfigs) {
      final station = gameState.stations[config.id];
      if (station == null) {
        continue;
      }
      final stationProfitMultiplier =
          _stationBonusManager.profitMultiplier(config.id, station.level);
      final stationSpeed =
          _stationBonusManager.productionSpeedMultiplier(config.id, station.level) *
              _managerUpgradeManager.stationSpeedMultiplier(gameState, config.id) *
              permanentStationSpeed *
              speedBoost;
      final worker = _workerManager.forStation(config.id);
      final workerBoost = (worker != null && gameState.workersHired.contains(worker.id))
          ? _workerManager.efficiencyForLevel(
                  worker,
                  gameState.workerLevels[worker.id] ?? 1,
                ) *
                permanentWorkerEfficiency
          : 0.0;
      final workerRateBoost =
          1 + workerBoost * EconomyBalanceConfig.workerAutomationRateMultiplier;
      totalCps += _economy.coinsPerSecond(config, station) *
          stationProfitMultiplier *
          expansion.incomeMultiplier *
          decorationIncome *
          managerIncome *
          prestigeIncome *
          incomeBoost *
          stationSpeed *
          workerRateBoost;
    }

    return _offlineIncomeSystem.calculate(
      totalCoinsPerSecond: totalCps,
      fromUtc: gameState.lastSavedAtUtc,
      toUtc: nowUtc,
      offlineMultiplier: EconomyBalanceConfig.offlineMultiplier,
    );
  }

  void _rollTaskWindows({required String todayKey}) {
    final weekKey = _weekKey(DateTime.now().toUtc());
    var next = state;
    var changed = false;
    if (next.dailyTaskDateKey != todayKey) {
      final daily = _taskManager.ensureDefaults(
        dailyTaskConfigs,
        <String, TaskState>{},
      );
      next = next.copyWith(dailyTasks: daily, dailyTaskDateKey: todayKey);
      changed = true;
    } else {
      final daily = _taskManager.ensureDefaults(dailyTaskConfigs, next.dailyTasks);
      if (daily.length != next.dailyTasks.length) {
        next = next.copyWith(dailyTasks: daily);
        changed = true;
      }
    }
    if (next.weeklyTaskDateKey != weekKey) {
      final weekly = _taskManager.ensureDefaults(
        weeklyTaskConfigs,
        <String, TaskState>{},
      );
      next = next.copyWith(weeklyTasks: weekly, weeklyTaskDateKey: weekKey);
      changed = true;
    } else {
      final weekly = _taskManager.ensureDefaults(weeklyTaskConfigs, next.weeklyTasks);
      if (weekly.length != next.weeklyTasks.length) {
        next = next.copyWith(weeklyTasks: weekly);
        changed = true;
      }
    }
    if (changed) {
      _setStateSafely(next);
    }
  }

  LoginStreakState _nextLoginStreak(LoginStreakState current, DateTime nowUtc) {
    final today = _dateKey(nowUtc);
    if (current.lastActiveDate == today) {
      return current;
    }
    final last = DateTime.tryParse(current.lastActiveDate);
    var streak = current.currentStreakDays;
    if (last == null) {
      streak = 1;
    } else {
      final localNow = nowUtc.toLocal();
      final localLast = last.toLocal();
      final diff = DateTime(localNow.year, localNow.month, localNow.day)
          .difference(DateTime(localLast.year, localLast.month, localLast.day))
          .inDays;
      streak = diff == 1 ? streak + 1 : 1;
    }
    final best = math.max(streak, current.bestStreakDays);
    final claimed = Set<int>.from(current.claimedMilestones);
    for (final milestone in const <int>[3, 7, 14, 30]) {
      if (streak >= milestone && !claimed.contains(milestone)) {
        claimed.add(milestone);
        _logAnalytics(AnalyticsEventType.streakMilestoneReached, <String, Object?>{'days': milestone});
      }
    }
    return current.copyWith(
      currentStreakDays: streak,
      bestStreakDays: best,
      lastActiveDate: today,
      claimedMilestones: claimed,
    );
  }

  String _dateKey(DateTime utc) {
    final d = utc.toLocal();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String _weekKey(DateTime utc) {
    final d = utc.toLocal();
    final first = DateTime.utc(d.year, 1, 1);
    final week = ((d.difference(first).inDays + first.weekday - 1) / 7).floor() + 1;
    return '${d.year}-W${week.toString().padLeft(2, '0')}';
  }

  GameState _addTaskMetric(GameState value, String metric, int delta) {
    if (delta <= 0) {
      return value;
    }
    final daily = _taskManager.applyMetric(
      configs: dailyTaskConfigs,
      states: value.dailyTasks,
      metric: metric,
      delta: delta,
    );
    final weekly = _taskManager.applyMetric(
      configs: weeklyTaskConfigs,
      states: value.weeklyTasks,
      metric: metric,
      delta: delta,
    );
    return value.copyWith(dailyTasks: daily, weeklyTasks: weekly);
  }

  Future<void> _persist() async {
    final now = DateTime.now().toUtc();
    _setStateSafely(
      state.copyWith(
        lastSavedAtUtc: now,
        lastSavedAtUtcMillis: now.millisecondsSinceEpoch,
        saveVersion: GameSaveData.currentSaveVersion,
      ),
    );
    final saveData = GameSaveData(
      saveVersion: GameSaveData.currentSaveVersion,
      coins: state.coins,
      lastSavedAtUtcMillis: now.millisecondsSinceEpoch,
      stations: state.stations,
      resources: state.resources,
      waitingCustomers: state.waitingCustomers,
      workersHired: state.workersHired,
      workerLevels: state.workerLevels,
      playerLevel: state.playerLevel,
      currentXp: state.currentXp,
      gems: state.gems,
      lifetimeCoinsEarned: state.lifetimeCoinsEarned,
      lifetimeCustomersServed: state.lifetimeCustomersServed,
      lifetimeCupsProduced: state.lifetimeCupsProduced,
      prestigePoints: state.prestigePoints,
      lifetimePrestigePoints: state.lifetimePrestigePoints,
      prestigeCount: state.prestigeCount,
      claimedMilestoneIds: state.claimedMilestoneIds,
      completedAchievementIds: state.completedAchievementIds,
      claimedAchievementIds: state.claimedAchievementIds,
      completedPrestigeAchievementIds: state.completedPrestigeAchievementIds,
      claimedPrestigeAchievementIds: state.claimedPrestigeAchievementIds,
      milestoneProgress: state.milestoneProgress,
      expansionStageId: state.expansionStageId,
      purchasedDecorationIds: state.purchasedDecorationIds,
      purchasedManagerIds: state.purchasedManagerIds,
      purchasedPermanentUpgradeIds: state.purchasedPermanentUpgradeIds,
      cafeOrders: state.cafeOrders,
      stationQueues: state.stationQueues,
      cafeTables: state.cafeTables,
      servedByCustomerType: state.servedByCustomerType,
      timesReachedCozyCafeAfterPrestige: state.timesReachedCozyCafeAfterPrestige,
      customerSpawnProgressSeconds: state.customerSpawnProgressSeconds,
      spawnBoostRemainingSeconds: state.spawnBoostRemainingSeconds,
      spawnBoostMultiplier: state.spawnBoostMultiplier,
      activeBoosts: state.activeBoosts,
      dailyReward: state.dailyReward,
      loginStreak: state.loginStreak,
      dailyTasks: state.dailyTasks,
      weeklyTasks: state.weeklyTasks,
      dailyTaskDateKey: state.dailyTaskDateKey,
      weeklyTaskDateKey: state.weeklyTaskDateKey,
      activeEvents: state.activeEvents,
      selectedThemeId: state.selectedThemeId,
      eventBeans: state.eventBeans,
      tipsEarned: state.tipsEarned,
      tipsReceived: state.tipsReceived,
      satisfiedOrders: state.satisfiedOrders,
      failedOrders: state.failedOrders,
      nextOrderSerial: state.nextOrderSerial,
      notificationPreferences: state.notificationPreferences,
      serviceIntegration: state.serviceIntegration,
    );
    await _saveService.save(saveData);
    unawaited(_economySyncService.queueSnapshot(state));
    unawaited(_cloudSaveService.pushLocalSave(saveData));
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    unawaited(_persist());
    super.dispose();
  }

  void _logAnalytics(
    AnalyticsEventType type, [
    Map<String, Object?> properties = const <String, Object?>{},
  ]) {
    unawaited(
      _analyticsService.logEvent(
        AnalyticsEvent(
          type: type,
          occurredAtUtcMillis: DateTime.now().toUtc().millisecondsSinceEpoch,
          properties: properties,
        ),
      ),
    );
  }

  void _setStateSafely(GameState nextState) {
    var normalizedState = _normalizeState(
      _syncAchievementProgress(_syncMilestoneProgress(nextState)),
    );
    if (_loaded && normalizedState.expansionStageId != state.expansionStageId) {
      normalizedState = _withUiEvent(normalizedState, event: 'expansion_unlocked');
      unawaited(_hapticsService.lightImpact(enabled: state.settings.hapticsEnabled));
      _audioService.playUnlock(enabled: state.settings.soundEnabled);
      _logAnalytics(AnalyticsEventType.expansionUnlock, <String, Object?>{
        'expansionId': normalizedState.expansionStageId,
      });
    }
    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    final isBuildPhase = schedulerPhase == SchedulerPhase.persistentCallbacks;
    if (!isBuildPhase) {
      state = normalizedState;
      return;
    }

    _queuedState = normalizedState;
    if (_stateCommitQueued) {
      return;
    }
    _stateCommitQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stateCommitQueued = false;
      final queued = _queuedState;
      _queuedState = null;
      if (queued != null) {
        state = queued;
      }
    });
  }

  GameState _awardXp(GameState value, int xp) {
    if (xp <= 0) {
      return value;
    }
    var level = value.playerLevel;
    var currentXp = value.currentXp + xp;
    var need = ProgressionBalanceConfig.xpToNextLevel(level);
    while (currentXp >= need) {
      currentXp -= need;
      level += 1;
      need = ProgressionBalanceConfig.xpToNextLevel(level);
    }
    return value.copyWith(playerLevel: level, currentXp: currentXp);
  }

  GameState _withDevCoinGrant(GameState value) {
    if (value.coins >= _devCoinGrant) {
      return value;
    }
    return value.copyWith(
      coins: _devCoinGrant,
      lifetimeCoinsEarned: math.max(value.lifetimeCoinsEarned, _devCoinGrant),
    );
  }

  GameState _applyExpansionStage(GameState value) {
    final expansion = _expansionManager.currentForState(value);
    if (expansion.id == value.expansionStageId) {
      return value;
    }
    final reachedCozyAfterPrestige = value.prestigeCount > 0 &&
        value.expansionStageId != 'cozy_cafe' &&
        expansion.id == 'cozy_cafe';
    return value.copyWith(
      expansionStageId: expansion.id,
      timesReachedCozyCafeAfterPrestige: reachedCozyAfterPrestige
          ? value.timesReachedCozyCafeAfterPrestige + 1
          : value.timesReachedCozyCafeAfterPrestige,
    );
  }

  GameState _syncMilestoneProgress(GameState value) {
    final nextProgress = <String, int>{};
    for (final config in _milestoneManager.configs) {
      nextProgress[config.id] = _milestoneManager.progressForConfig(value, config);
    }
    return value.copyWith(milestoneProgress: nextProgress);
  }

  GameState _normalizeState(GameState value) {
    final stations = _ensureAllStations(value.stations);
    final normalizedExpansion = _expansionManager.byId(value.expansionStageId);
    final maxQueue = _maxQueueCustomersForState(value);
    var queue = List<String>.from(value.waitingCustomerTypes);
    if (queue.length > maxQueue) {
      queue = queue.sublist(0, maxQueue);
    }
    final validStationIds = stationConfigs.map((s) => s.id).toSet();
    final cafeOrders = value.cafeOrders
        .where((order) =>
            order.requestedItems.isNotEmpty &&
            order.phase != CafeOrderPhase.completed &&
            order.phase != CafeOrderPhase.failed)
        .toList(growable: false);
    final orderIds = cafeOrders.map((order) => order.orderId).toSet();
    final stationQueues = <String, List<StationTaskState>>{};
    for (final stationId in validStationIds) {
      final source = value.stationQueues[stationId] ?? const <StationTaskState>[];
      stationQueues[stationId] = source
          .where((task) => orderIds.contains(task.orderId) && !task.delivered)
          .toList(growable: false);
    }
    final tableIds = value.cafeTables.map((table) => table.tableId).toSet();
    final cafeTables = <CafeTableState>[
      for (final fallback in _defaultCafeTables())
        if (!tableIds.contains(fallback.tableId)) fallback,
      ...value.cafeTables,
    ];
    final validManagerIds = _managerUpgradeManager.all.map((m) => m.id).toSet();
    final validWorkerIds = _workerManager.allWorkers.map((w) => w.id).toSet();
    final validDecorationIds = _decorationManager.all.map((d) => d.id).toSet();
    final validCustomerTypeIds = _customerTypeManager.all.map((c) => c.id).toSet();
    final managers = value.purchasedManagerIds.where(validManagerIds.contains).toSet();
    final workers = value.workersHired.where(validWorkerIds.contains).toSet();
    final workerLevels = Map<String, int>.fromEntries(
      value.workerLevels.entries.where((entry) => validWorkerIds.contains(entry.key)),
    );
    final decorations = value.purchasedDecorationIds.where(validDecorationIds.contains).toSet();
    final validAchievementIds = _achievementManager.configs.map((a) => a.id).toSet();
    final claimedAchievements = value.claimedAchievementIds
        .where(validAchievementIds.contains)
        .toSet();
    final validPermanentUpgradeIds = _permanentUpgradeManager.all.map((u) => u.id).toSet();
    final permanentUpgrades =
        value.purchasedPermanentUpgradeIds.where(validPermanentUpgradeIds.contains).toSet();
    final validPrestigeAchievementIds =
        _prestigeAchievementManager.configs.map((a) => a.id).toSet();
    final claimedPrestigeAchievements = value.claimedPrestigeAchievementIds
        .where(validPrestigeAchievementIds.contains)
        .toSet();
    final nowUtc = DateTime.now().toUtc();
    final boosts = _boostManager.sanitize(value.activeBoosts, nowUtc);
    final validThemeIds = liveThemeConfigs.map((t) => t.id).toSet();
    final validEventIds = _limitedEventManager.all.map((e) => e.id).toSet();
    final dailyTasks = _taskManager.ensureDefaults(dailyTaskConfigs, value.dailyTasks);
    final weeklyTasks = _taskManager.ensureDefaults(weeklyTaskConfigs, value.weeklyTasks);
    return value.copyWith(
      stations: stations,
      expansionStageId: normalizedExpansion.id,
      waitingCustomerTypes: queue,
      waitingCustomers: queue.length,
      workersHired: workers,
      workerLevels: workerLevels,
      purchasedDecorationIds: decorations,
      purchasedManagerIds: managers,
      purchasedPermanentUpgradeIds: permanentUpgrades,
      cafeOrders: cafeOrders,
      stationQueues: stationQueues,
      cafeTables: cafeTables,
      servedByCustomerType: Map<String, int>.fromEntries(
        value.servedByCustomerType.entries.where((entry) => validCustomerTypeIds.contains(entry.key)),
      ),
      completedAchievementIds: Set<String>.from(value.completedAchievementIds),
      claimedAchievementIds: claimedAchievements,
      completedPrestigeAchievementIds:
          Set<String>.from(value.completedPrestigeAchievementIds),
      claimedPrestigeAchievementIds: claimedPrestigeAchievements,
      activeBoosts: boosts,
      selectedThemeId: validThemeIds.contains(value.selectedThemeId)
          ? value.selectedThemeId
          : 'default_coffee',
      activeEvents: value.activeEvents.copyWith(
        activeEventIds: value.activeEvents.activeEventIds.where(validEventIds.contains).toSet(),
      ),
      eventBeans: value.eventBeans < 0 ? 0 : value.eventBeans,
      dailyTasks: dailyTasks,
      weeklyTasks: weeklyTasks,
    );
  }

  GameState _syncAchievementProgress(GameState value) {
    final completed = _achievementManager.completedIdsForState(value);
    final completedPrestige = _prestigeAchievementManager.completedIdsForState(value);
    return value.copyWith(
      completedAchievementIds: completed,
      completedPrestigeAchievementIds: completedPrestige,
    );
  }

  int _maxQueueCustomersForState(GameState gameState) {
    final expansion = _expansionManager.byId(gameState.expansionStageId);
    return EconomyBalanceConfig.maxQueueCustomers +
        _decorationManager.queueCapacityBonus(gameState.purchasedDecorationIds) +
        expansion.queueCapacityBonus;
  }

  List<String> _defaultQueueTypes(int count) {
    final clamped = count.clamp(0, EconomyBalanceConfig.maxQueueCustomers).toInt();
    return List<String>.filled(clamped, 'regular');
  }

  Map<String, StationState> _ensureAllStations(Map<String, StationState> stations) {
    final next = <String, StationState>{};
    for (final cfg in stationConfigs) {
      next[cfg.id] = stations[cfg.id] ??
          StationState(
          stationId: cfg.id,
          level: 1,
          isUnlocked: cfg.unlockCost == 0,
          autoEnabled: cfg.unlockCost == 0,
        );
    }
    return next;
  }

  GameState _buildPrestigeRunResetState({
    required DateTime nowUtc,
    required int awardedPrestigePoints,
  }) {
    const resetPlayerLevel = PrestigeBalanceConfig.resetPlayerLevelOnPrestige;
    final resetStations = _ensureAllStations(const <String, StationState>{});
    return GameState(
      coins: 0,
      stations: resetStations,
      lastSavedAtUtc: nowUtc,
      resources: const GameResources(coffeeCups: 0, servedCustomers: 0),
      waitingCustomers: 0,
      waitingCustomerTypes: const <String>[],
      workersHired: const <String>{},
      workerLevels: const <String, int>{},
      playerLevel: resetPlayerLevel ? 1 : state.playerLevel,
      currentXp: resetPlayerLevel ? 0 : state.currentXp,
      gems: state.gems,
      lifetimeCoinsEarned: state.lifetimeCoinsEarned,
      lifetimeCustomersServed: state.lifetimeCustomersServed,
      lifetimeCupsProduced: state.lifetimeCupsProduced,
      prestigePoints: state.prestigePoints + awardedPrestigePoints,
      lifetimePrestigePoints: state.lifetimePrestigePoints + awardedPrestigePoints,
      prestigeCount: state.prestigeCount + 1,
      claimedMilestoneIds: const <String>{},
      completedAchievementIds: state.completedAchievementIds,
      claimedAchievementIds: state.claimedAchievementIds,
      completedPrestigeAchievementIds: state.completedPrestigeAchievementIds,
      claimedPrestigeAchievementIds: state.claimedPrestigeAchievementIds,
      milestoneProgress: const <String, int>{},
      expansionStageId: 'small_cart',
      purchasedDecorationIds: const <String>{},
      purchasedManagerIds: const <String>{},
      purchasedPermanentUpgradeIds: state.purchasedPermanentUpgradeIds,
      cafeOrders: const <CafeOrderState>[],
      stationQueues: const <String, List<StationTaskState>>{},
      cafeTables: _defaultCafeTables(),
      servedByCustomerType: state.servedByCustomerType,
      timesReachedCozyCafeAfterPrestige: state.timesReachedCozyCafeAfterPrestige,
      spawnBoostRemainingSeconds: 0,
      spawnBoostMultiplier: 1.0,
      activeBoosts: const <String, BoostState>{},
      offlineIncomeRewardedClaimed: true,
      dailyReward: state.dailyReward,
      loginStreak: state.loginStreak,
      dailyTasks: state.dailyTasks,
      weeklyTasks: state.weeklyTasks,
      dailyTaskDateKey: state.dailyTaskDateKey,
      weeklyTaskDateKey: state.weeklyTaskDateKey,
      activeEvents: state.activeEvents,
      selectedThemeId: state.selectedThemeId,
      eventBeans: state.eventBeans,
      notificationPreferences: state.notificationPreferences,
      settings: state.settings,
      tutorial: state.tutorial,
      saveVersion: GameSaveData.currentSaveVersion,
      lastSavedAtUtcMillis: nowUtc.millisecondsSinceEpoch,
    );
  }

  static List<CafeTableState> _defaultCafeTables() {
    return const <CafeTableState>[
      CafeTableState(tableId: 'table_1', isUnlocked: true),
      CafeTableState(tableId: 'table_2', isUnlocked: true),
      CafeTableState(tableId: 'table_3', isUnlocked: true),
      CafeTableState(tableId: 'table_4', isUnlocked: true),
      CafeTableState(tableId: 'standby_1', isUnlocked: true),
    ];
  }

  static GameState _initialState(DateTime nowUtc) {
    return GameState(
      coins: 0,
      stations: const {},
      lastSavedAtUtc: nowUtc,
      resources: const GameResources(coffeeCups: 0, servedCustomers: 0),
      waitingCustomers: 0,
      waitingCustomerTypes: const <String>[],
      workersHired: const <String>{},
      workerLevels: const <String, int>{},
      playerLevel: 1,
      currentXp: 0,
      gems: 0,
      lifetimeCoinsEarned: 0,
      lifetimeCustomersServed: 0,
      lifetimeCupsProduced: 0,
      prestigePoints: 0,
      lifetimePrestigePoints: 0,
      prestigeCount: 0,
      claimedMilestoneIds: const <String>{},
      completedAchievementIds: const <String>{},
      claimedAchievementIds: const <String>{},
      completedPrestigeAchievementIds: const <String>{},
      claimedPrestigeAchievementIds: const <String>{},
      milestoneProgress: const <String, int>{},
      expansionStageId: 'small_cart',
      purchasedDecorationIds: const <String>{},
      purchasedManagerIds: const <String>{},
      purchasedPermanentUpgradeIds: const <String>{},
      cafeOrders: const <CafeOrderState>[],
      stationQueues: const <String, List<StationTaskState>>{},
      cafeTables: _defaultCafeTables(),
      servedByCustomerType: const <String, int>{},
      timesReachedCozyCafeAfterPrestige: 0,
      spawnBoostRemainingSeconds: 0,
      spawnBoostMultiplier: 1.0,
      activeBoosts: const <String, BoostState>{},
      offlineIncomeRewardedClaimed: true,
      settings: SettingsState.defaults,
      tutorial: TutorialState.initial,
      saveVersion: GameSaveData.currentSaveVersion,
      lastSavedAtUtcMillis: nowUtc.millisecondsSinceEpoch,
      uiEventCounter: 0,
      lastUiEvent: '',
    );
  }

  GameState _withUiEvent(
    GameState value, {
    required String event,
    String? stationId,
  }) {
    return value.copyWith(
      uiEventCounter: value.uiEventCounter + 1,
      lastUiEvent: event,
      lastUiEventStationId: stationId,
      clearLastUiEventStationId: stationId == null,
    );
  }
}

class _ReceptionOrderResult {
  const _ReceptionOrderResult(
    this.queueTypes,
    this.orders,
    this.stationQueues,
    this.tables,
    this.ordersAdded,
  );

  final List<String> queueTypes;
  final List<CafeOrderState> orders;
  final Map<String, List<StationTaskState>> stationQueues;
  final List<CafeTableState> tables;
  final int ordersAdded;
}

class _OrderProcessResult {
  const _OrderProcessResult({
    required this.orders,
    required this.stationQueues,
    required this.tables,
    required this.coins,
    required this.lifetimeCoins,
    required this.servedCustomers,
    required this.lifetimeServed,
    required this.servedByType,
    required this.tipsEarned,
    required this.tipsReceived,
    required this.satisfiedOrders,
    required this.failedOrders,
  });

  final List<CafeOrderState> orders;
  final Map<String, List<StationTaskState>> stationQueues;
  final List<CafeTableState> tables;
  final double coins;
  final double lifetimeCoins;
  final int servedCustomers;
  final int lifetimeServed;
  final Map<String, int> servedByType;
  final double tipsEarned;
  final int tipsReceived;
  final int satisfiedOrders;
  final int failedOrders;
}

class _OrderMenuItem {
  const _OrderMenuItem(this.id, this.stationId, this.label, this.icon);

  final String id;
  final String stationId;
  final String label;
  final String icon;
}
