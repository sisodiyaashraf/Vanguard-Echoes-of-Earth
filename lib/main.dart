import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/main_menu_screen.dart';
import 'package:vanguard_echoes_of_earth/game/settings_screen.dart';
import 'package:vanguard_echoes_of_earth/game/hero_select_screen.dart';
import 'package:vanguard_echoes_of_earth/game/level_select_screen.dart';
import 'package:vanguard_echoes_of_earth/game/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SaveManager.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vanguard: Echoes of Earth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainMenuScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/hero-select': (context) => const HeroSelectScreen(),
        '/level-select': (context) => const LevelSelectScreen(),
        '/game': (context) => const GameScreen(),
      },
    );
  }
}
