import '../models/city_config.dart';

const List<CityConfig> cityConfigs = [
  CityConfig(
    cityLevel: 1,
    name: 'Beanwick',
    description: 'A quiet riverside town where every morning starts with a fresh pour.',
    accentColorHex: '#6D4C41',
  ),
  CityConfig(
    cityLevel: 2,
    name: 'Roastport',
    description: 'Salt air and dark roasts — the dockworkers here demand the strong stuff.',
    accentColorHex: '#E65100',
  ),
  CityConfig(
    cityLevel: 3,
    name: 'Cappushire',
    description: 'Rolling hills, cobblestone lanes, and foam art that locals call high culture.',
    accentColorHex: '#558B2F',
  ),
  CityConfig(
    cityLevel: 4,
    name: 'Brûlée Bay',
    description: 'Where sugar meets heat — caramelized drinks are practically currency here.',
    accentColorHex: '#F9A825',
  ),
  CityConfig(
    cityLevel: 5,
    name: 'Lungo Heights',
    description: 'A city built on ambition and long pulls — slow, deliberate, worth the wait.',
    accentColorHex: '#1565C0',
  ),
  CityConfig(
    cityLevel: 6,
    name: 'Macchiato Mesa',
    description: 'Sun-baked and bold, a desert outpost famous for its stained marble counters.',
    accentColorHex: '#AD1457',
  ),
  CityConfig(
    cityLevel: 7,
    name: 'Crema Cove',
    description: 'A hidden harbour town where the golden crema on every shot is non-negotiable.',
    accentColorHex: '#00838F',
  ),
  CityConfig(
    cityLevel: 8,
    name: 'Doppio Falls',
    description: 'Twin waterfalls, double shots — the city has always lived in pairs.',
    accentColorHex: '#6A1B9A',
  ),
  CityConfig(
    cityLevel: 9,
    name: 'Cortado Cliffs',
    description: 'Perched above the fog line, where a ratio of milk to coffee is a matter of honour.',
    accentColorHex: '#2E7D32',
  ),
  CityConfig(
    cityLevel: 10,
    name: 'Ristretto Ridge',
    description: 'Short, intense, and unforgettable — this mountain city keeps nothing diluted.',
    accentColorHex: '#4E342E',
  ),
];

/// Returns the [CityConfig] for the given [cityLevel].
/// If [cityLevel] exceeds the defined list, it cycles back and appends a
/// Roman numeral suffix (II, III, IV…) so the name remains distinct.
CityConfig cityForLevel(int cityLevel) {
  final count = cityConfigs.length;
  final index = (cityLevel - 1) % count;
  final base = cityConfigs[index];
  final cycle = (cityLevel - 1) ~/ count;

  if (cycle == 0) return base;

  final suffix = _romanNumeral(cycle + 1);
  return CityConfig(
    cityLevel: cityLevel,
    name: '${base.name} $suffix',
    description: base.description,
    accentColorHex: base.accentColorHex,
  );
}

String _romanNumeral(int n) {
  const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const symbols = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
  final buffer = StringBuffer();
  var remaining = n;
  for (var i = 0; i < values.length; i++) {
    while (remaining >= values[i]) {
      buffer.write(symbols[i]);
      remaining -= values[i];
    }
  }
  return buffer.toString();
}
