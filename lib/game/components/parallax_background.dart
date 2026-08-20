import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/widgets.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';

class ParallaxBackground extends ParallaxComponent<VanguardGame> {
  ParallaxBackground();

  Future<void> changeLevelBackground(String assetPath) async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData(assetPath),
      ],
      baseVelocity: Vector2.zero(),
      velocityMultiplierDelta: Vector2.zero(),
      repeat: ImageRepeat.repeatX,
      fill: LayerFill.height,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (parallax != null && game.heroes.isNotEmpty) {
      final hero = game.activeHero;
      parallax!.baseVelocity.x = -hero.velocity.x * 0.05;
    }
  }
}
