import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_registry.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final VanguardGame game;

  const LevelCompleteOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final currentConfig = game.currentLevelConfig;
    int nextLevelIndex = -1;
    if (currentConfig != null) {
      nextLevelIndex = LevelRegistry.levels.indexWhere((l) => l.id == currentConfig.id) + 1;
    }
    final hasNextLevel = nextLevelIndex > 0 &&
        nextLevelIndex < LevelRegistry.levels.length &&
        currentConfig != null &&
        LevelRegistry.levels[nextLevelIndex].heroId == currentConfig.heroId;

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
              Text(
                'MISSION CLEAR',
                style: GoogleFonts.pressStart2p(
                  color: const Color(0xFF00FFCC),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  shadows: [
                    const Shadow(
                      color: Color(0xFF00FFCC),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Successfully completed:\n"${currentConfig?.displayName ?? 'Mission'}"',
                style: GoogleFonts.vt323(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.3,
                  letterSpacing: 0.5,
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
                  child: Text(
                    'NEXT LEVEL',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                  Navigator.pop(context);
                },
                child: Text(
                  'LEVEL SELECT',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
