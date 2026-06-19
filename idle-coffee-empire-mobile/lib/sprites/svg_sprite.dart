import 'package:flame_svg/flame_svg.dart';

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
    // Customers (assets/customers/)
    customerCasual   = await _load('assets/customers/customer_casual.svg');
    customerBusiness = await _load('assets/customers/customer_business.svg');
    customerHipster  = await _load('assets/customers/customer_hipster.svg');
    customerKid      = await _load('assets/customers/customer_kid.svg');
    customerElder    = await _load('assets/customers/customer_elder.svg');

    // Chefs (assets/chefs/)
    chefHeadBarista  = await _load('assets/chefs/chef_head_barista.svg');
    chefEspresso     = await _load('assets/chefs/chef_espresso.svg');
    chefPastry       = await _load('assets/chefs/chef_pastry.svg');
    chefTrainee      = await _load('assets/chefs/chef_trainee.svg');
    chefManager      = await _load('assets/chefs/chef_manager.svg');

    // Emotions (assets/ui/)
    emotionHappy     = await _load('assets/ui/emotion_happy.svg');
    emotionImpatient = await _load('assets/ui/emotion_impatient.svg');
    emotionAngry     = await _load('assets/ui/emotion_angry.svg');

    // Items (assets/items/)
    itemEspresso     = await _load('assets/items/espresso.svg');
    itemLatte        = await _load('assets/items/latte.svg');
    itemColdBrew     = await _load('assets/items/cold_brew.svg');

    // UI (assets/ui/)
    coffeeCoin       = await _load('assets/ui/coffee_coin.svg');
    boostSpeed       = await _load('assets/ui/boost_speed.svg');
    boostCps         = await _load('assets/ui/boost_cps.svg');
    boostPrestige    = await _load('assets/ui/boost_prestige.svg');

    // Decor (assets/decor/)
    prestigeTrophy   = await _load('assets/decor/prestige_trophy.svg');

    // Stations (assets/ui/)
    stationEspresso  = await _load('assets/ui/station_espresso.svg');
    stationGrinder   = await _load('assets/ui/station_grinder.svg');
    stationPastry    = await _load('assets/ui/station_pastry.svg');
  }

  static Future<Svg?> _load(String path) async {
    try {
      return await Svg.load(path);
    } catch (_) {
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
}
