import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/hud_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/dialogue_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/level_selection_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/pause_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/game_over_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/level_complete_overlay.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_config.dart';
import 'package:vanguard_echoes_of_earth/game/tutorial_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final VanguardGame game;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = ModalRoute.of(context)!.settings.arguments as LevelConfig;
    game = VanguardGame(initialLevelConfig: config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<VanguardGame>(
        game: game,
        overlayBuilderMap: {
          'hud': (context, game) => GameHud(game: game),
          'dialogue': (context, game) => DialogueOverlay(game: game),
          'level_selection': (context, game) => LevelSelectionOverlay(game: game),
          'pause': (context, game) => PauseOverlay(game: game),
          'game_over': (context, game) => GameOverOverlay(game: game),
          'level_complete': (context, game) => LevelCompleteOverlay(game: game),
          'tutorial': (context, game) => TutorialOverlay(game: game),
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }
}
