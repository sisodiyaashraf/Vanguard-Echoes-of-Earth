import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/widgets.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';

class ParallaxBackground extends ParallaxComponent<VanguardGame> {
  ParallaxBackground() : super(priority: -10);

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
    
    // Fill the entire screen canvas (screen coordinates)
    position = Vector2.zero();
    size = game.size;

    if (parallax != null) {
      // Scroll the background layers proportional to active hero's velocity
      parallax!.baseVelocity.x = -game.activeHero.velocity.x * 0.12;
    }
  }
}
