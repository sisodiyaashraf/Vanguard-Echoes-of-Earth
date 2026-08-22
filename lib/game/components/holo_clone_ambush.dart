import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class HoloClone extends SpriteAnimationComponent with HasGameReference<VanguardGame> {
  double _elapsedTime = 0.0;
  final double _duration;
  final double durationMultiplier;

  HoloClone({
    required Vector2 spawnPosition,
    required double scaleX,
    this.durationMultiplier = 1.0,
  })  : _duration = CombatConstants.holoCloneDuration * durationMultiplier,
        super(
          position: spawnPosition,
          size: Vector2.all(128),
          anchor: Anchor.center,
          priority: 4,
        ) {
    scale.x = scaleX;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load Kitsune's idle animation (4 frames, 375x750 cell size)
    animation = await game.loadSpriteAnimation(
      'characters/Kitsune (Holographic).png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: Vector2(375, 750),
        amountPerRow: 4,
      ),
    );

    // Make the clone translucent (decoy)
    paint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.5);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsedTime += dt;
    if (_elapsedTime >= _duration) {
      removeFromParent();
    }
  }
}

// Spawns two static HoloClones on either side of Kitsune
void spawnHoloCloneAmbush(VanguardGame game, Vector2 heroPosition, double heroScaleX, {double durationMultiplier = 1.0}) {
  // Left clone offset
  game.world.add(
    HoloClone(
      spawnPosition: heroPosition + Vector2(-60.0, 0.0),
      scaleX: heroScaleX,
      durationMultiplier: durationMultiplier,
    ),
  );

  // Right clone offset
  game.world.add(
    HoloClone(
      spawnPosition: heroPosition + Vector2(60.0, 0.0),
      scaleX: heroScaleX,
      durationMultiplier: durationMultiplier,
    ),
  );
}
