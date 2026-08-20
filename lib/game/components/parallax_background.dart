import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/widgets.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';

class ParallaxBackground extends ParallaxComponent<VanguardGame> {
  double? _lastCamX;

  ParallaxBackground();

  Future<void> changeLevelBackground(String assetPath) async {
    _lastCamX = null;
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
    
    // Keep background centered on camera and scaled to camera visible size
    position = game.camera.viewfinder.position;
    anchor = Anchor.center;
    size = game.camera.viewfinder.visibleGameSize ?? Vector2(640, 360);

    if (parallax != null) {
      final currentCamX = game.camera.viewfinder.position.x;
      _lastCamX ??= currentCamX;
      final diffX = currentCamX - _lastCamX!;
      _lastCamX = currentCamX;
      
      // Scroll by setting baseVelocity proportional to camera speed
      parallax!.baseVelocity.x = dt > 0 ? -diffX / dt * 0.18 : 0.0;
    }
  }
}
