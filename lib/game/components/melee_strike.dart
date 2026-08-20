import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';

class MeleeStrike extends PositionComponent with HasGameReference<VanguardGame> {
  final double duration = 0.2;
  double _elapsed = 0.0;

  MeleeStrike({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}
