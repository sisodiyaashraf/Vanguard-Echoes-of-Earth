import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/hud_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/dialogue_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/level_selection_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/pause_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/game_over_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/level_complete_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: Scaffold(
        body: GameWidget<VanguardGame>(
          game: VanguardGame(),
          overlayBuilderMap: {
            'hud': (context, game) => GameHud(game: game),
            'dialogue': (context, game) => DialogueOverlay(game: game),
            'level_selection': (context, game) => LevelSelectionOverlay(game: game),
            'pause': (context, game) => PauseOverlay(game: game),
            'game_over': (context, game) => GameOverOverlay(game: game),
            'level_complete': (context, game) => LevelCompleteOverlay(game: game),
          },
          initialActiveOverlays: const ['hud'],
        ),
      ),
    );
  }
}

