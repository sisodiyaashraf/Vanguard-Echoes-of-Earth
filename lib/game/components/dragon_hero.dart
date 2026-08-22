import 'package:flame/components.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/plasma_shockwave.dart';
import 'package:vanguard_echoes_of_earth/game/components/base_hero.dart';

class DragonHero extends BaseHero {
  static const double runGroundOffset = 0.0;
  static const double idleGroundOffset = 0.0;

  DragonHero({
    super.position,
  });

  @override
  String get heroName => 'Dragon';

  @override
  double get meleeAttackDuration => CombatConstants.meleeAttackDuration;

  @override
  double get basePowerCooldown => CombatConstants.plasmaCooldown;

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

    final transformationAnimation = await loadHorizontalAnimation(
      'characters/ChatGPT Image Aug 18 2026 11_38_26 A-60kb.png',
      4,
      0.15,
    );

    animations = {
      HeroState.idle: idleAnimation,
      HeroState.run: runAnimation,
      HeroState.jump: jumpAnimation,
      HeroState.attack: attackAnimation,
      HeroState.superpower: superpowerAnimation,
      HeroState.transformation: transformationAnimation,
    };

    current = HeroState.idle;
  }

  @override
  double get groundContactOffset {
    if (current == HeroState.run) {
      return runGroundOffset;
    }
    return idleGroundOffset;
  }

  @override
  void spawnPower() {
    // Spawn shockwave in front of Dragon based on facing direction (scale.x.sign)
    final direction = scale.x.sign;
    final spawnOffset = Vector2(direction * 80.0, 0.0);
    final spawnPos = position + spawnOffset;

    final hasReach = hasSkillUnlocked('dragon_flame_reach');
    final shockwave = PlasmaShockwave(
      direction: direction,
      spawnPosition: spawnPos,
      sizeMultiplier: hasReach ? 1.3 : 1.0,
      lifetimeMultiplier: hasReach ? 1.3 : 1.0,
    );

    game.world.add(shockwave);
  }
}
