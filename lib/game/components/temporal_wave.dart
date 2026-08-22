import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class TemporalWave extends SpriteComponent with HasGameReference<VanguardGame> {
  final double direction;
  double _elapsedTime = 0.0;

  TemporalWave({
    required this.direction,
    required Vector2 spawnPosition,
  }) : super(
          position: spawnPosition,
          size: Vector2(96, 96), // Wider than the standard plasma shockwave
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load VFX sheet and slice the purple burst (Row 2, Column 3)
    final vfxSheet = await game.images.load('characters/VFX (effects, transparent).png');
    sprite = Sprite(
      vfxSheet,
      srcPosition: Vector2(1000, 500),
      srcSize: Vector2(500, 500),
    );

    // Apply horizontal flip if moving left
    if (direction < 0) {
      flipHorizontallyAroundCenter();
    }

    // Add circular hitbox for collision detection
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move forward at a fixed speed
    position.x += direction * CombatConstants.temporalSpeed * dt;

    _elapsedTime += dt;
    if (_elapsedTime >= CombatConstants.temporalLifetime) {
      removeFromParent();
    }
  }
}
