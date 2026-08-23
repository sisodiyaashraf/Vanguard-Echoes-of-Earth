import 'package:vanguard_echoes_of_earth/game/core/localization.dart';

class GameOverOverlay extends StatelessWidget {
  final VanguardGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final isSurvival = game.currentLevelConfig?.id == 'survival';

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF111218),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF5252).withValues(alpha: 0.4),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5252).withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF5252),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                isSurvival ? 'SURVIVAL OVER' : AppLocalizations.translate('clear_failed'),
                style: GoogleFonts.pressStart2p(
                  color: const Color(0xFFFF5252),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  shadows: [
                    const Shadow(
                      color: Color(0xFFFF5252),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isSurvival
                    ? 'WAVES SURVIVED: ${game.survivalWavesSurvived}\nENEMIES DEFEATED: ${game.survivalEnemiesDefeated}'
                    : 'Your active hero was defeated.',
                style: GoogleFonts.vt323(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (game.currentLevelConfig != null) {
                    game.loadLevel(game.currentLevelConfig!);
                  }
                },
                child: Text(
                  'RETRY',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
