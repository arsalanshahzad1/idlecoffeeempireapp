class ThemeConfig {
  const ThemeConfig({
    required this.id,
    required this.name,
    required this.accentHex,
    required this.backgroundHex,
    required this.floorTintHex,
    required this.hudTintHex,
    required this.environmentAccentHex,
    this.floorStyleAsset,
    this.hudStyleAsset,
  });

  final String id;
  final String name;
  final String accentHex;
  final String backgroundHex;
  final String floorTintHex;
  final String hudTintHex;
  final String environmentAccentHex;
  final String? floorStyleAsset;
  final String? hudStyleAsset;
}

const List<ThemeConfig> liveThemeConfigs = <ThemeConfig>[
  ThemeConfig(
    id: 'default_coffee',
    name: 'Default Coffee',
    accentHex: '#6D4C41',
    backgroundHex: '#F5E6D3',
    floorTintHex: '#E6D5B8',
    hudTintHex: '#F4E4C9',
    environmentAccentHex: '#B08968',
    floorStyleAsset: 'assets/images/floors/default_coffee/floor.png',
    hudStyleAsset: 'assets/images/themes/default_coffee/hud.png',
  ),
  ThemeConfig(
    id: 'holiday_cafe',
    name: 'Holiday Cafe',
    accentHex: '#B71C1C',
    backgroundHex: '#E8F5E9',
    floorTintHex: '#D7CCC8',
    hudTintHex: '#FDECEA',
    environmentAccentHex: '#2E7D32',
    floorStyleAsset: 'assets/images/floors/holiday_cafe/floor.png',
    hudStyleAsset: 'assets/images/themes/holiday_cafe/hud.png',
  ),
  ThemeConfig(
    id: 'summer_iced',
    name: 'Summer Cafe',
    accentHex: '#0277BD',
    backgroundHex: '#E1F5FE',
    floorTintHex: '#D0ECF8',
    hudTintHex: '#E0F7FA',
    environmentAccentHex: '#26C6DA',
    floorStyleAsset: 'assets/images/floors/summer_iced/floor.png',
    hudStyleAsset: 'assets/images/themes/summer_iced/hud.png',
  ),
  ThemeConfig(
    id: 'night_shift',
    name: 'Night Cafe',
    accentHex: '#37474F',
    backgroundHex: '#ECEFF1',
    floorTintHex: '#B0BEC5',
    hudTintHex: '#CFD8DC',
    environmentAccentHex: '#78909C',
    floorStyleAsset: 'assets/images/floors/night_shift/floor.png',
    hudStyleAsset: 'assets/images/themes/night_shift/hud.png',
  ),
  ThemeConfig(
    id: 'luxury_cafe',
    name: 'Luxury Cafe',
    accentHex: '#8D6E63',
    backgroundHex: '#FFF8E1',
    floorTintHex: '#D7CCC8',
    hudTintHex: '#FBE9E7',
    environmentAccentHex: '#D4AF37',
    floorStyleAsset: 'assets/images/floors/luxury_cafe/floor.png',
    hudStyleAsset: 'assets/images/themes/luxury_cafe/hud.png',
  ),
];
