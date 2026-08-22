import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class WaterBlade extends SpriteComponent with HasGameReference<VanguardGame> {
  final Vector2 velocity;
  double _elapsedTime = 0.0;

  WaterBlade({
    required this.velocity,
    required Vector2 spawnPosition,
  }) : super(
          position: spawnPosition,
          size: Vector2(48, 48), // Small agile projectile
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load VFX sheet and slice the water wave splash (Row 2, Column 2)
    final vfxSheet = await game.images.load('characters/VFX (effects, transparent).png');
    sprite = Sprite(
      vfxSheet,
      srcPosition: Vector2(500, 500),
      srcSize: Vector2(500, 500),
    );

    // Flip sprite horizontally if moving left
    if (velocity.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Add a circular hitbox for collision mapping
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply linear velocity
    position += velocity * dt;

    _elapsedTime += dt;
    if (_elapsedTime >= CombatConstants.waterBladeLifetime) {
      removeFromParent();
    }
  }
}

// Spawns 3 water blades in a spread pattern
void spawnWaterBladeBarrage(VanguardGame game, Vector2 startPosition, double direction) {
  final speed = CombatConstants.waterBladeSpeed;
  
  // 1. Straight blade
  game.world.add(
    WaterBlade(
      velocity: Vector2(direction * speed, 0),
      spawnPosition: startPosition.clone(),
    ),
  );

  // 2. Upward spread blade
  game.world.add(
    WaterBlade(
      velocity: Vector2(direction * speed, -80),
      spawnPosition: startPosition.clone(),
    ),
  );

  // 3. Downward spread blade
  game.world.add(
    WaterBlade(
      velocity: Vector2(direction * speed, 80),
      spawnPosition: startPosition.clone(),
    ),
  );

  // Automatically remove them using their own lifetime manager component or schedule
  // Let's make each blade remove itself after its lifetime
  // Inside WaterBlade.update, we can easily track lifetime!
}
