import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:vanguard_echoes_of_earth/game/level/level.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';

class LevelParallax extends ParallaxComponent<VanguardGame> {
  LevelParallax();

  Future<void> changeLevel(Level level) async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData(level.backgroundAsset),
      ],
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2.zero(),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (parallax != null && game.heroes.isNotEmpty) {
      final hero = game.activeHero;
      parallax!.sharedParameters.baseVelocity.x = -hero.velocity.x * 0.05;
    }
  }
}
