import 'package:flame/components.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/water_blade_barrage.dart';
import 'package:vanguard_echoes_of_earth/game/components/base_hero.dart';

class SharkHero extends BaseHero {
  SharkHero({
    super.position,
  });

  @override
  double get meleeAttackDuration => CombatConstants.meleeAttackDuration;

  @override
  double get powerCooldown => CombatConstants.waterBladeCooldown;

  @override
  int get powerEnergyCost => CombatConstants.waterBladeEnergyCost;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Idle animation (4 frames, 375x500 cell size)
    final idleAnimation = await game.loadSpriteAnimation(
      'characters/Shark (Hydrokinetic Agility).png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: Vector2(375, 500),
        amountPerRow: 4,
      ),
    );

    // Run animation (6 frames, 250x250 cell size)
    final runAnimation = await game.loadSpriteAnimation(
      'characters/Shark -run.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.10,
        textureSize: Vector2(250, 250),
        amountPerRow: 6,
      ),
    );

    // Jump animation (2 frames, 500x500 cell size, starting at y=0)
    final jumpAnimation = await game.loadSpriteAnimation(
      'characters/Shark -jump and attack.png',
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.20,
        textureSize: Vector2(500, 500),
        amountPerRow: 3,
      ),
    );

    // Attack animation (3 frames, 500x500 cell size, starting at y=500)
    final attackAnimation = await game.loadSpriteAnimation(
      'characters/Shark -jump and attack.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: meleeAttackDuration / 3,
        textureSize: Vector2(500, 500),
        texturePosition: Vector2(0, 500),
        amountPerRow: 3,
        loop: false,
      ),
    );

    animations = {
      HeroState.idle: idleAnimation,
      HeroState.run: runAnimation,
      HeroState.jump: jumpAnimation,
      HeroState.attack: attackAnimation,
    };

    current = HeroState.idle;
  }

  @override
  void spawnPower() {
    final direction = scale.x.sign;
    final spawnOffset = Vector2(direction * 50.0, 0.0);
    final spawnPos = position + spawnOffset;

    // Trigger the spread projectile barrage
    spawnWaterBladeBarrage(game, spawnPos, direction);
  }
}
