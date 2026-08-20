import 'package:flutter/material.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_registry.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final VanguardGame game;

  const LevelCompleteOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Check if there is a next level configured
    final currentConfig = game.currentLevelConfig;
    int nextLevelIndex = -1;
    if (currentConfig != null) {
      nextLevelIndex = LevelRegistry.levels.indexWhere((l) => l.id == currentConfig.id) + 1;
    }
    final hasNextLevel = nextLevelIndex > 0 && nextLevelIndex < LevelRegistry.levels.length;

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF111218),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00FFCC).withValues(alpha: 0.4),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFCC).withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF00FFCC),
                size: 54,
              ),
              const SizedBox(height: 16),
              const Text(
                'MISSION CLEAR',
                style: TextStyle(
                  color: Color(0xFF00FFCC),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: Color(0xFF00FFCC),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Successfully completed:\n"${currentConfig?.displayName ?? 'Mission'}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (hasNextLevel) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFCC),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    game.overlays.remove('level_complete');
                    game.loadLevel(LevelRegistry.levels[nextLevelIndex]);
                  },
                  child: const Text(
                    'NEXT LEVEL',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  game.overlays.remove('level_complete');
                  game.overlays.add('level_selection');
                },
                child: const Text('LEVEL SELECT', style: TextStyle(letterSpacing: 1.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
