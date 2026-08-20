import 'package:flutter/material.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';

class PauseOverlay extends StatelessWidget {
  final VanguardGame game;

  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF111218),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00FFCC).withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFCC).withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MISSION PAUSED',
                style: TextStyle(
                  color: Color(0xFF00FFCC),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: Color(0xFF00FFCC),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                  game.paused = false;
                  game.overlays.remove('pause');
                },
                child: const Text(
                  'RESUME',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
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
                  game.paused = false;
                  game.overlays.remove('pause');
                  if (game.currentLevelConfig != null) {
                    game.loadLevel(game.currentLevelConfig!);
                  }
                },
                child: const Text('RESTART LEVEL'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  game.paused = false;
                  game.overlays.remove('pause');
                  game.overlays.add('level_selection');
                },
                child: const Text('LEVEL SELECT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
