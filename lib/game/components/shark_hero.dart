import 'package:flame/components.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/water_blade_barrage.dart';
import 'package:vanguard_echoes_of_earth/game/components/base_hero.dart';

class SharkHero extends BaseHero {
  static const double runGroundOffset = 26.6;
  static const double idleGroundOffset = 0.0;

  SharkHero({
    super.position,
  });

  @override
  String get heroName => 'Shark';

  @override
  double get meleeAttackDuration => CombatConstants.meleeAttackDuration;

  @override
  double get basePowerCooldown => CombatConstants.waterBladeCooldown;

  @override
  int get powerEnergyCost => CombatConstants.waterBladeEnergyCost;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Idle animation (4 frames, 375x750 cell size)
    final idleAnimation = await game.loadSpriteAnimation(
      'characters/Shark (Hydrokinetic Agility).png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: Vector2(375, 750),
        amountPerRow: 4,
      ),
    );

    // Run animation (6 frames, 250x750 cell size)
    final runAnimation = await game.loadSpriteAnimation(
      'characters/Shark -run.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.10,
        textureSize: Vector2(250, 750),
        amountPerRow: 6,
      ),
    );

    // Jump animation (2 frames, 500x500 cell size, starting at y=0, with 3 columns per row)
    final jumpAnimation = await game.loadSpriteAnimation(
      'characters/Shark -jump and attack.png',
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.20,
        textureSize: Vector2(500, 500),
        amountPerRow: 3,
      ),
    );

    // Attack animation (3 frames, 500x500 cell size, starting at y=500, with 3 columns per row)
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

    // Load Superpower casting animation (3 frames)
    final superpowerAnimation = await loadHorizontalAnimation(
      'characters/Shark — Hydrokinetic Agility(superpower).png',
      3,
      0.15,
    );

    // Load Transformation animation (2 frames)
    final transformationAnimation = await loadHorizontalAnimation(
      'characters/Shark — Hydrokinetic Agility(Transformation).png',
      2,
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
    final direction = scale.x.sign;
    final spawnOffset = Vector2(direction * 50.0, 0.0);
    final spawnPos = position + spawnOffset;

    final hasRiptide = hasSkillUnlocked('shark_water_blades');
    spawnWaterBladeBarrage(
      game,
      spawnPos,
      direction,
      damage: hasRiptide ? (CombatConstants.waterBladeDamage * 1.25).toInt() : CombatConstants.waterBladeDamage,
    );
  }
}
