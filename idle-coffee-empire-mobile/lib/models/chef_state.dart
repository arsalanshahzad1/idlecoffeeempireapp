class ChefEquippedGear {
  const ChefEquippedGear({
    this.hatId,
    this.shirtId,
    this.pantsId,
    this.shoesId,
  });

  // Phase 2: each String? will be swapped for a real GearItem reference.
  final String? hatId;
  final String? shirtId;
  final String? pantsId;
  final String? shoesId;

  ChefEquippedGear copyWith({
    String? hatId,
    bool clearHat = false,
    String? shirtId,
    bool clearShirt = false,
    String? pantsId,
    bool clearPants = false,
    String? shoesId,
    bool clearShoes = false,
  }) {
    return ChefEquippedGear(
      hatId: clearHat ? null : (hatId ?? this.hatId),
      shirtId: clearShirt ? null : (shirtId ?? this.shirtId),
      pantsId: clearPants ? null : (pantsId ?? this.pantsId),
      shoesId: clearShoes ? null : (shoesId ?? this.shoesId),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'hatId': hatId,
      'shirtId': shirtId,
      'pantsId': pantsId,
      'shoesId': shoesId,
    };
  }

  factory ChefEquippedGear.fromMap(Map<dynamic, dynamic> map) {
    return ChefEquippedGear(
      hatId: map['hatId'] as String?,
      shirtId: map['shirtId'] as String?,
      pantsId: map['pantsId'] as String?,
      shoesId: map['shoesId'] as String?,
    );
  }

  static const ChefEquippedGear empty = ChefEquippedGear();
}

class ChefState {
  const ChefState({
    required this.chefId,
    required this.name,
    this.equippedGear = ChefEquippedGear.empty,
  });

  final String chefId;
  final String name;
  final ChefEquippedGear equippedGear;

  ChefState copyWith({
    String? name,
    ChefEquippedGear? equippedGear,
  }) {
    return ChefState(
      chefId: chefId,
      name: name ?? this.name,
      equippedGear: equippedGear ?? this.equippedGear,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chefId': chefId,
      'name': name,
      'equippedGear': equippedGear.toMap(),
    };
  }

  factory ChefState.fromMap(Map<dynamic, dynamic> map) {
    final rawGear = map['equippedGear'];
    return ChefState(
      chefId: map['chefId'] as String,
      name: map['name'] as String? ?? 'Chef',
      equippedGear: rawGear is Map
          ? ChefEquippedGear.fromMap(rawGear)
          : ChefEquippedGear.empty,
    );
  }

  static const ChefState starter = ChefState(
    chefId: 'chef_1',
    name: 'Chef',
  );
}
