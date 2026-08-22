import 'package:flame/components.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/seismic_slam.dart';
import 'package:vanguard_echoes_of_earth/game/components/base_hero.dart';

class TRexHero extends BaseHero {
  static const double runGroundOffset = 25.0;
  static const double idleGroundOffset = 0.0;

  TRexHero({
    super.position,
  });

  @override
  String get heroName => 'T-Rex';

  @override
  double get meleeAttackDuration => CombatConstants.meleeAttackDuration;

  @override
  double get basePowerCooldown => CombatConstants.seismicCooldown;

  @override
  int get powerEnergyCost => CombatConstants.seismicEnergyCost;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Idle animation (4 frames, 375x557 cell size)
    final idleAnimation = await game.loadSpriteAnimation(
      'characters/Hero 2 T-Rex (Seismic Hammer).png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: Vector2(375, 557),
        amountPerRow: 4,
      ),
    );

    // Run animation (6 frames, 250x534 cell size)
    final runAnimation = await game.loadSpriteAnimation(
      'characters/T-Rex -run.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.10,
        textureSize: Vector2(250, 534),
        amountPerRow: 6,
      ),
    );

    // Jump animation (2 frames, 500x500 cell size, starting at y=0, with 3 columns per row)
    final jumpAnimation = await game.loadSpriteAnimation(
      'characters/T-Rex -run -jump and attack.png',
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.20,
        textureSize: Vector2(500, 500),
        amountPerRow: 3,
      ),
    );

    // Attack animation (3 frames, 500x500 cell size, starting at y=500, with 3 columns per row)
    final attackAnimation = await game.loadSpriteAnimation(
      'characters/T-Rex -run -jump and attack.png',
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
      'characters/T-Rex — Seismic Hammer(superpower).png',
      3,
      0.15,
    );

    // Load Transformation animation (4 frames)
    final transformationAnimation = await loadHorizontalAnimation(
      'characters/T-Rex — Seismic Hammer(transformation).png',
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
    // Spawn Seismic Slam ground effect at feet
    final feetPosition = position.clone() + Vector2(0, size.y / 2);
    final hasResonance = hasSkillUnlocked('trex_seismic_size');
    final slam = SeismicSlam(
      spawnPosition: feetPosition,
      sizeMultiplier: hasResonance ? 1.3 : 1.0,
    );
    game.world.add(slam);
  }
}
