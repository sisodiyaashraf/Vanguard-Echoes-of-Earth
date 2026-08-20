import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flame_audio/flame_audio.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/core/physics_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/melee_strike.dart';
import 'package:vanguard_echoes_of_earth/game/components/plasma_shockwave.dart';
import 'package:vanguard_echoes_of_earth/game/components/seismic_slam.dart';
import 'package:vanguard_echoes_of_earth/game/components/temporal_wave.dart';
import 'package:vanguard_echoes_of_earth/game/components/water_blade_barrage.dart';
import 'package:vanguard_echoes_of_earth/game/components/platform.dart';
import 'package:vanguard_echoes_of_earth/game/components/element_particle.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';

class HollowEnemy extends SpriteAnimationGroupComponent<EnemyAnimState>
    with HasGameReference<VanguardGame>, CollisionCallbacks {
  final EnemyVariant variant;
  final Vector2 velocity = Vector2.zero();

  late int health;
  late final int maxHealth;
  late final int contactDamage;
  late final double speed;
  late final double aggroRange;
  late final double attackRange;

  double _hurtTimer = 0.0;
  double _deathTimer = 0.0;
  double _contactDamageCooldownTimer = 0.0;

  late final RectangleHitbox _bodyHitbox;

  // Track which specific attack instances have already hit this enemy
  final Set<PositionComponent> _receivedHits = {};

  HollowEnemy({
    required this.variant,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(128),
          anchor: Anchor.center,
        ) {
    maxHealth = CombatConstants.getEnemyMaxHealth(variant);
    health = maxHealth;
    contactDamage = CombatConstants.getEnemyContactDamage(variant);
    speed = CombatConstants.getEnemySpeed(variant);
    aggroRange = CombatConstants.getEnemyAggroRange(variant);
    attackRange = CombatConstants.getEnemyAttackRange(variant);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = await game.images.load('characters/Enemy sprites (The Hollow).png');
    final row = variant.index;

    // Slice frames for the specified enemy type row (height offset is row * 250)
    final idleAnimation = SpriteAnimation.spriteList(
      List.generate(4, (i) => Sprite(
        image,
        srcPosition: Vector2(i * 250.0, row * 250.0),
        srcSize: Vector2(250.0, 250.0),
      )),
      stepTime: 0.15,
    );

    final chaseAnimation = SpriteAnimation.spriteList(
      List.generate(6, (i) => Sprite(
        image,
        srcPosition: Vector2(i * 250.0, row * 250.0),
        srcSize: Vector2(250.0, 250.0),
      )),
      stepTime: 0.10,
    );

    final attackAnimation = SpriteAnimation.spriteList(
      List.generate(2, (i) => Sprite(
        image,
        srcPosition: Vector2((4 + i) * 250.0, row * 250.0),
        srcSize: Vector2(250.0, 250.0),
      )),
      stepTime: 0.15,
    );

    final hurtAnimation = SpriteAnimation.spriteList(
      [Sprite(
        image,
        srcPosition: Vector2(0, row * 250.0),
        srcSize: Vector2(250.0, 250.0),
      )],
      stepTime: 0.15,
    );

    final deadAnimation = SpriteAnimation.spriteList(
      [Sprite(
        image,
        srcPosition: Vector2(0, row * 250.0),
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
      paint.color = paint.color.withValues(alpha: (1.0 - (_deathTimer / 0.5)).clamp(0.0, 1.0));
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

    // Apply gravity
    velocity.y += PhysicsConstants.gravity * dt;
    position.y += velocity.y * dt;

    // Platform collisions
    final halfHeight = size.y / 2;
    final halfWidth = size.x / 2;
    final platforms = game.world.children.whereType<Platform>();
    for (var platform in platforms) {
      final groundTop = platform.position.y;
      final groundLeft = platform.position.x;
      final groundRight = platform.position.x + platform.size.x;

      if (position.x + halfWidth > groundLeft && position.x - halfWidth < groundRight) {
        if (velocity.y >= 0 &&
            position.y + halfHeight >= groundTop &&
            position.y + halfHeight - velocity.y * dt <= groundTop + 10) {
          position.y = groundTop - halfHeight;
          velocity.y = 0;
          break;
        }
      }
    }

    // Safety check: remove if falls out of bounds
    if (position.y > 800) {
      removeFromParent();
      return;
    }

    // AI Logic
    final hero = game.activeHero;
    final toHero = hero.position - position;
    final distance = toHero.length;

    if (distance > aggroRange) {
      current = EnemyAnimState.idle;
      velocity.x = 0.0;
    } else if (distance > attackRange) {
      current = EnemyAnimState.chase;
      final directionX = toHero.x.sign;
      velocity.x = directionX * speed;
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

    // Spawn element-colored hit particles
    final heroName = game.activeHero.heroName;
    Color particleColor;
    switch (heroName) {
      case 'Dragon':
        particleColor = const Color(0xFFFF4500);
        break;
      case 'T-Rex':
        particleColor = const Color(0xFFFFD700);
        break;
      case 'Curator':
        particleColor = const Color(0xFF9400D3);
        break;
      case 'Shark':
        particleColor = const Color(0xFF1E90FF);
        break;
      case 'Kitsune':
      default:
        particleColor = const Color(0xFF00FFCC);
        break;
    }

    final rand = Random();
    for (int i = 0; i < 8; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 50 + rand.nextDouble() * 100;
      final vel = Vector2(cos(angle) * speed, sin(angle) * speed - 50);
      game.world.add(ElementParticle(
        position: position.clone(),
        velocity: vel,
        color: particleColor,
        radius: 3.0 + rand.nextDouble() * 3.0,
        duration: 0.3 + rand.nextDouble() * 0.3,
      ));
    }

    // Play hit SFX
    if (source is MeleeStrike) {
      FlameAudio.play('melee_hit.wav', volume: SaveManager.getSfxVolume());
    } else {
      FlameAudio.play('enemy_hit.wav', volume: SaveManager.getSfxVolume());
    }

    if (health <= 0) {
      current = EnemyAnimState.dead;
      _bodyHitbox.collisionType = CollisionType.inactive;
      _deathTimer = 0.0;
      FlameAudio.play('enemy_death.wav', volume: SaveManager.getSfxVolume());
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
