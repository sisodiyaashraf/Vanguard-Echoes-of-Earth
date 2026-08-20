import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/melee_strike.dart';
import 'package:vanguard_echoes_of_earth/game/components/plasma_shockwave.dart';
import 'package:vanguard_echoes_of_earth/game/components/seismic_slam.dart';
import 'package:vanguard_echoes_of_earth/game/components/temporal_wave.dart';
import 'package:vanguard_echoes_of_earth/game/components/water_blade_barrage.dart';

class HollowEnemy extends SpriteAnimationGroupComponent<EnemyAnimState>
    with HasGameReference<VanguardGame>, CollisionCallbacks {
  final int enemyType; // 0 to 3 for visual types
  final Vector2 velocity = Vector2.zero();

  int health = CombatConstants.enemyMaxHealth;
  final int maxHealth = CombatConstants.enemyMaxHealth;
  final int contactDamage = CombatConstants.enemyContactDamage;

  double _hurtTimer = 0.0;
  double _deathTimer = 0.0;
  double _contactDamageCooldownTimer = 0.0;

  late final RectangleHitbox _bodyHitbox;

  // Track which specific attack instances have already hit this enemy
  final Set<PositionComponent> _receivedHits = {};

  HollowEnemy({
    required this.enemyType,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(128),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = await game.images.load('characters/Enemy sprites (The Hollow).png');

    // Slice frames for the specified enemy type row (height offset is enemyType * 250)
    final idleAnimation = SpriteAnimation.spriteList(
      List.generate(4, (i) => Sprite(
        image,
        srcPosition: Vector2(i * 250.0, enemyType * 250.0),
        srcSize: Vector2(250.0, 250.0),
      )),
      stepTime: 0.15,
    );

    final chaseAnimation = SpriteAnimation.spriteList(
      List.generate(6, (i) => Sprite(
        image,
        srcPosition: Vector2(i * 250.0, enemyType * 250.0),
        srcSize: Vector2(250.0, 250.0),
      )),
      stepTime: 0.10,
    );

    final attackAnimation = SpriteAnimation.spriteList(
      List.generate(2, (i) => Sprite(
        image,
        srcPosition: Vector2((4 + i) * 250.0, enemyType * 250.0),
        srcSize: Vector2(250.0, 250.0),
      )),
      stepTime: 0.15,
    );

    final hurtAnimation = SpriteAnimation.spriteList(
      [Sprite(
        image,
        srcPosition: Vector2(0, enemyType * 250.0),
        srcSize: Vector2(250.0, 250.0),
      )],
      stepTime: 0.15,
    );

    final deadAnimation = SpriteAnimation.spriteList(
      [Sprite(
        image,
        srcPosition: Vector2(0, enemyType * 250.0),
        srcSize: Vector2(250.0, 250.0),
      )],
      stepTime: 0.15,
    );

    animations = {
      EnemyAnimState.idle: idleAnimation,
      EnemyAnimState.chase: chaseAnimation,
      EnemyAnimState.attack: attackAnimation,
      EnemyAnimState.hurt: hurtAnimation,
      EnemyAnimState.dead: deadAnimation,
    };

    current = EnemyAnimState.idle;

    // Add centered physical hitbox for receiving damage
    _bodyHitbox = RectangleHitbox(
      size: Vector2(60, 90),
      position: Vector2(34, 19),
    );
    add(_bodyHitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_contactDamageCooldownTimer > 0) {
      _contactDamageCooldownTimer -= dt;
    }

    if (health <= 0) {
      current = EnemyAnimState.dead;
      _deathTimer += dt;
      paint.opacity = (1.0 - (_deathTimer / 0.5)).clamp(0.0, 1.0);
      if (_deathTimer >= 0.5) {
        removeFromParent();
      }
      return;
    }

    if (_hurtTimer > 0) {
      _hurtTimer -= dt;
      final tick = (_hurtTimer * 20).toInt();
      paint.colorFilter = tick % 2 == 0
          ? const ColorFilter.mode(Colors.white, BlendMode.srcATop)
          : const ColorFilter.mode(Color(0xFFFF3333), BlendMode.srcATop);
      if (_hurtTimer <= 0.0) {
        paint.colorFilter = null;
        current = EnemyAnimState.idle;
      }
      return;
    }

    final hero = game.activeHero;
    final toHero = hero.position - position;
    final distance = toHero.length;

    if (distance > CombatConstants.enemyAggroRange) {
      current = EnemyAnimState.idle;
      velocity.x = 0.0;
    } else if (distance > CombatConstants.enemyAttackRange) {
      current = EnemyAnimState.chase;
      final directionX = toHero.x.sign;
      velocity.x = directionX * CombatConstants.enemySpeed;
      position.x += velocity.x * dt;

      if (velocity.x < 0 && scale.x > 0) {
        scale.x = -1;
      } else if (velocity.x > 0 && scale.x < 0) {
        scale.x = 1;
      }
    } else {
      current = EnemyAnimState.attack;
      velocity.x = 0.0;

      final directionX = toHero.x.sign;
      if (directionX < 0 && scale.x > 0) {
        scale.x = -1;
      } else if (directionX > 0 && scale.x < 0) {
        scale.x = 1;
      }

      if (_contactDamageCooldownTimer <= 0) {
        hero.takeDamage(contactDamage);
        _contactDamageCooldownTimer = CombatConstants.enemyContactDamageCooldown;
      }
    }
  }

  void _takeDamage(int damage, PositionComponent source) {
    if (health <= 0) return;
    if (_receivedHits.contains(source)) return;

    _receivedHits.add(source);
    health -= damage;

    _hurtTimer = 0.15;
    current = EnemyAnimState.hurt;
    animationTicker?.reset();

    if (health <= 0) {
      current = EnemyAnimState.dead;
      _bodyHitbox.collisionType = CollisionType.inactive;
      _deathTimer = 0.0;
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is MeleeStrike) {
      _takeDamage(CombatConstants.basicAttackDamage, other);
    } else if (other is PlasmaShockwave) {
      _takeDamage(CombatConstants.plasmaDamage, other);
    } else if (other is SeismicSlam) {
      _takeDamage(CombatConstants.seismicDamage, other);
    } else if (other is TemporalWave) {
      _takeDamage(CombatConstants.temporalDamage, other);
    } else if (other is WaterBlade) {
      _takeDamage(CombatConstants.waterBladeDamage, other);
    }
  }
}
