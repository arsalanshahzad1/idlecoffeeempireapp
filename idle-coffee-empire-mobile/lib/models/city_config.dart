import 'package:flutter/material.dart';

class CityConfig {
  const CityConfig({
    required this.cityLevel,
    required this.name,
    required this.description,
    required this.accentColorHex,
  });

  final int cityLevel;
  final String name;
  final String description;
  final String accentColorHex;

  Color get accentColor {
    final hex = accentColorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
