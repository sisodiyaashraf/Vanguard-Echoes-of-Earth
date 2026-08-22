import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class SeismicSlam extends SpriteComponent with HasGameReference<VanguardGame> {
  double _elapsedTime = 0.0;
  final double _duration = CombatConstants.seismicDuration;
  late final Vector2 _targetSize;
  final int damage;
  final double sizeMultiplier;

  SeismicSlam({
    required Vector2 spawnPosition,
    this.damage = CombatConstants.seismicDamage,
    this.sizeMultiplier = 1.0,
  })  : _targetSize = Vector2(160 * sizeMultiplier, 160 * sizeMultiplier),
        super(
          position: spawnPosition,
          anchor: Anchor.bottomCenter,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load VFX sheet and slice the earth blast (Row 2, Column 1)
    final vfxSheet = await game.images.load('characters/VFX (effects, transparent).png');
    sprite = Sprite(
      vfxSheet,
      srcPosition: Vector2(0, 500),
      srcSize: Vector2(500, 500),
    );

    // Start very small for the expansion effect
    size = Vector2.zero();

    // Add rectangle hitbox for ground collision mapping
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsedTime += dt;
    if (_elapsedTime >= _duration) {
      removeFromParent();
      return;
    }

    // Proportional growth/expansion outward
    final progress = (_elapsedTime / _duration).clamp(0.0, 1.0);
    size = _targetSize * progress;
  }
}
