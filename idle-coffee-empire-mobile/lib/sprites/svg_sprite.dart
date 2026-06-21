import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/foundation.dart';

/// Loads every SVG asset once at game startup.
///
/// All fields are nullable so a missing file degrades to the existing
/// shape-fallback renderer without crashing.
class SvgSprites {
  SvgSprites._();

  // ── Customers ─────────────────────────────────────────────────────────────
  static Svg? customerCasual;
  static Svg? customerBusiness;
  static Svg? customerHipster;
  static Svg? customerKid;
  static Svg? customerElder;

  // ── Chefs / workers ───────────────────────────────────────────────────────
  static Svg? chefHeadBarista;
  static Svg? chefEspresso;
  static Svg? chefPastry;
  static Svg? chefTrainee;
  static Svg? chefManager;

  // ── Customer emotions (exit emoji + patience feedback) ────────────────────
  static Svg? emotionHappy;
  static Svg? emotionImpatient;
  static Svg? emotionAngry;

  // ── Order items ───────────────────────────────────────────────────────────
  static Svg? itemEspresso;
  static Svg? itemLatte;
  static Svg? itemColdBrew;

  // ── UI / HUD ──────────────────────────────────────────────────────────────
  static Svg? coffeeCoin;
  static Svg? boostSpeed;
  static Svg? boostCps;
  static Svg? boostPrestige;

  // ── Decorations ───────────────────────────────────────────────────────────
  static Svg? prestigeTrophy;

  // ── Stations ──────────────────────────────────────────────────────────────
  static Svg? stationEspresso;
  static Svg? stationGrinder;
  static Svg? stationPastry;

  // ── Load ──────────────────────────────────────────────────────────────────

  static Future<void> loadAll() async {
    // Customers
    customerCasual   = await _load('customers/customer_casual.svg');
    customerBusiness = await _load('customers/customer_business.svg');
    customerHipster  = await _load('customers/customer_hipster.svg');
    customerKid      = await _load('customers/customer_kid.svg');
    customerElder    = await _load('customers/customer_elder.svg');

    // Chefs
    chefHeadBarista  = await _load('chefs/chef_head_barista.svg');
    chefEspresso     = await _load('chefs/chef_espresso.svg');
    chefPastry       = await _load('chefs/chef_pastry.svg');
    chefTrainee      = await _load('chefs/chef_trainee.svg');
    chefManager      = await _load('chefs/chef_manager.svg');

    // Emotions
    emotionHappy     = await _load('ui/emotion_happy.svg');
    emotionImpatient = await _load('ui/emotion_impatient.svg');
    emotionAngry     = await _load('ui/emotion_angry.svg');

    // Items
    itemEspresso     = await _load('items/espresso.svg');
    itemLatte        = await _load('items/latte.svg');
    itemColdBrew     = await _load('items/cold_brew.svg');

    // UI / HUD
    coffeeCoin       = await _load('ui/coffee_coin.svg');
    boostSpeed       = await _load('ui/boost_speed.svg');
    boostCps         = await _load('ui/boost_cps.svg');
    boostPrestige    = await _load('ui/boost_prestige.svg');

    // Decor
    prestigeTrophy   = await _load('decor/prestige_trophy.svg');

    // Stations
    stationEspresso  = await _load('ui/station_espresso.svg');
    stationGrinder   = await _load('ui/station_grinder.svg');
    stationPastry    = await _load('ui/station_pastry.svg');
  }

  static Future<Svg?> _load(String path) async {
    try {
      return await Svg.load(path);
    } catch (e, stack) {
      debugPrint('SvgSprites._load FAILED: $path — $e');
      debugPrint('$stack');
      return null;
    }
  }

  // ── Mapping helpers ───────────────────────────────────────────────────────

  /// Returns the SVG for a customer type ID as used by the game engine.
  ///
  /// Game IDs: regular, student, office_worker, tourist, influencer, vip_guest
  /// SVG names: casual, business, hipster, kid, elder
  static Svg? forCustomerType(String typeId) {
    return switch (typeId) {
      'regular'       => customerCasual,
      'student'       => customerKid,
      'office_worker' => customerBusiness,
      'tourist'       => customerHipster,
      'influencer'    => customerBusiness,
      'vip_guest'     => customerElder,
      _               => customerCasual,
    };
  }

  /// Returns the SVG for a worker ID as used by the game engine.
  static Svg? forWorkerId(String workerId) {
    return switch (workerId) {
      'barista_worker'      => chefHeadBarista,
      'cashier_worker'      => chefHeadBarista,
      'burger_cook'         => chefEspresso,
      'frother_assistant'   => chefEspresso,
      'cold_brew_specialist'=> chefEspresso,
      'pastry_chef'         => chefPastry,
      'dessert_baker'       => chefPastry,
      'vip_host'            => chefManager,
      _                     => chefTrainee,
    };
  }

  /// Returns the emotion SVG for the customer exit feedback.
  static Svg? forExitMood({required bool happy}) =>
      happy ? emotionHappy : emotionAngry;

  /// Returns the patience warning SVG (shown when patience is low).
  static Svg? get patienceWarning => emotionImpatient;

  /// Returns the SVG for a station ID.
  static Svg? forStationId(String stationId) {
    return switch (stationId) {
      'espresso_machine' => stationEspresso,
      'coffee_grinder'   => stationGrinder,
      'pastry_display'   => stationPastry,
      _                  => null,
    };
  }

  /// Returns the best item SVG to represent an order from a given station,
  /// used in customer order bubbles.
  static Svg? forItemStationId(String stationId) {
    return switch (stationId) {
      'espresso_machine' => itemEspresso,
      'coffee_grinder'   => itemLatte,
      'pastry_display'   => itemColdBrew,
      _                  => null,
    };
  }

  /// Returns the SVG icon for a boost ID.
  static Svg? forBoostId(String boostId) {
    return switch (boostId) {
      'income_x2'      => boostCps,
      'production_x2'  => boostSpeed,
      'customer_rush'  => boostPrestige,
      _                => null,
    };
  }

  /// Returns the asset path (relative to assets/) for a boost icon — for use
  /// with [SvgCanvasWidget] which loads from path rather than a pre-loaded Svg.
  static String? pathForBoostId(String boostId) {
    return switch (boostId) {
      'income_x2'      => 'ui/boost_cps.svg',
      'production_x2'  => 'ui/boost_speed.svg',
      'customer_rush'  => 'ui/boost_prestige.svg',
      _                => null,
    };
  }
}
