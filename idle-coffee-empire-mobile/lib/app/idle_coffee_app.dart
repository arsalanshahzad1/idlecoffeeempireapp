import 'package:flutter/material.dart';

import '../features/game/game_screen.dart';
import '../visuals/visual_config.dart';

class IdleCoffeeApp extends StatelessWidget {
  const IdleCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idle Coffee Empire',
      debugShowCheckedModeBanner: false,
      theme: VisualConfig.appTheme(),
      home: const GameScreen(),
    );
  }
}
