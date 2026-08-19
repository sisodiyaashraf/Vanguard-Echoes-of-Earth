import 'package:flame/components.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/plasma_shockwave.dart';
import 'package:vanguard_echoes_of_earth/game/components/base_hero.dart';

class DragonHero extends BaseHero {
  DragonHero({
    super.position,
  });

  @override
  double get meleeAttackDuration => CombatConstants.meleeAttackDuration;

  @override
  double get powerCooldown => CombatConstants.plasmaCooldown;

  @override
  int get powerEnergyCost => CombatConstants.plasmaEnergyCost;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load animations using sequenced frame data
    final idleAnimation = await game.loadSpriteAnimation(
      'dragon_idle.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: Vector2.all(128),
      ),
    );

    final runAnimation = await game.loadSpriteAnimation(
      'dragon_run.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.10,
        textureSize: Vector2.all(128),
      ),
    );

    final jumpAnimation = await game.loadSpriteAnimation(
      'dragon_jump.png',
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.20,
        textureSize: Vector2.all(128),
      ),
    );

    final attackAnimation = await game.loadSpriteAnimation(
      'dragon_attack.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: meleeAttackDuration / 3,
        textureSize: Vector2.all(128),
        loop: false,
      ),
    );

    // Load Superpower casting animation (3 frames)
    final superpowerAnimation = await loadHorizontalAnimation(
      'characters/Dragon — Kinetic Scale(superpower).png',
      3,
      0.15,
    );

    animations = {
      HeroState.idle: idleAnimation,
      HeroState.run: runAnimation,
      HeroState.jump: jumpAnimation,
      HeroState.attack: attackAnimation,
      HeroState.superpower: superpowerAnimation,
    };

    current = HeroState.idle;
  }

  @override
  void spawnPower() {
    // Spawn shockwave in front of Dragon based on facing direction (scale.x.sign)
    final direction = scale.x.sign;
    final spawnOffset = Vector2(direction * 80.0, 0.0);
    final spawnPos = position + spawnOffset;

    final shockwave = PlasmaShockwave(
      direction: direction,
      spawnPosition: spawnPos,
    );

    game.world.add(shockwave);
  }
}
