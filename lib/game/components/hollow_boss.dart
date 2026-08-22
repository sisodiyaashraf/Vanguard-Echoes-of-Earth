import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flame_audio/flame_audio.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/core/physics_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_enemy.dart';
import 'package:vanguard_echoes_of_earth/game/components/platform.dart';
import 'package:vanguard_echoes_of_earth/game/components/base_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/element_particle.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';

class HollowBoss extends HollowEnemy {
  final String bossType;

  double _telegraphTimer = 0.0;
  double _attackCooldownTimer = 0.0;
  double _specialStateTimer = 0.0;

  bool isTelegraphing = false;
  bool isAttackingPattern = false;
  bool isInvulnerable = false;

  String activeAttack = '';
  final Random _rand = Random();

  HollowBoss({
    required this.bossType,
    required super.position,
  }) : super(
          variant: EnemyVariant.boss,
        );

  @override
  void update(double dt) {
    if (health <= 0) {
      paint.colorFilter = null; // Ensure boss color filters are also cleared on death
      super.update(dt);
      return;
    }

    if (_hurtTimer > 0) {
      super.update(dt);
      return;
    }

    _applyBossTint();

    if (_attackCooldownTimer > 0) {
      _attackCooldownTimer -= dt;
    }

    if (isTelegraphing) {
      _telegraphTimer -= dt;
      // Visual charging flash
      final flashTick = (_telegraphTimer * 15).toInt();
      if (flashTick % 2 == 0) {
        paint.colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
      } else {
        _applyBossTint();
      }

      if (_telegraphTimer <= 0) {
        isTelegraphing = false;
        _executeAttack();
      }
      _applyGravityAndCollisions(dt);
      return;
    }

    if (isAttackingPattern) {
      _specialStateTimer -= dt;
      if (_specialStateTimer <= 0) {
        isAttackingPattern = false;
        activeAttack = '';
        current = EnemyAnimState.idle;
        _attackCooldownTimer = CombatConstants.bossAttackCooldown;
      } else {
        _updateAttackPattern(dt);
      }
      _applyGravityAndCollisions(dt);
      return;
    }

    if (isInvulnerable) {
      _specialStateTimer -= dt;
      if (_specialStateTimer <= 0) {
        isInvulnerable = false;
      }
      final wave = 0.3 + 0.4 * sin(game.timeSinceCreation * 12);
      paint.color = Colors.white.withValues(alpha: wave);
    } else {
      paint.color = Colors.white;
    }

    // AI Check for attack range
    final hero = game.activeHero;
    final toHero = hero.position - position;
    final distance = toHero.length;

    if (distance <= attackRange && _attackCooldownTimer <= 0) {
      _startAttackTelegraph();
    } else {
      super.update(dt);
    }
  }

  void _applyBossTint() {
    Color filterColor;
    switch (bossType.toLowerCase()) {
      case 'dragon':
        filterColor = const Color(0xFFFF4500);
        break;
      case 't-rex':
        filterColor = const Color(0xFFFFD700);
        break;
      case 'curator':
        filterColor = const Color(0xFF9400D3);
        break;
      case 'shark':
        filterColor = const Color(0xFF1E90FF);
        break;
      case 'kitsune':
        filterColor = const Color(0xFF00FFCC);
        break;
      default:
        filterColor = const Color(0xFFFF3333);
        break;
    }
    paint.colorFilter = ColorFilter.mode(filterColor.withValues(alpha: 0.4), BlendMode.srcATop);
  }

  void _startAttackTelegraph() {
    isTelegraphing = true;
    _telegraphTimer = CombatConstants.bossTelegraphDuration;
    velocity.x = 0;
    current = EnemyAnimState.attack;

    // Face the player
    final hero = game.activeHero;
    final toHero = hero.position - position;
    final directionX = toHero.x.sign;
    if (directionX < 0 && scale.x > 0) {
      scale.x = -1;
    } else if (directionX > 0 && scale.x < 0) {
      scale.x = 1;
    }

    activeAttack = _rand.nextBool() ? 'attack1' : 'attack2';
    FlameAudio.play('enemy_hit.wav', volume: SaveManager.getSfxVolume() * 0.7);
  }

  void _executeAttack() {
    final facingDirection = scale.x.sign;

    switch (bossType.toLowerCase()) {
      case 'dragon':
        if (activeAttack == 'attack1') {
          // Ground Fire Line
          isAttackingPattern = true;
          _specialStateTimer = 0.5;
          for (int i = 0; i < 5; i++) {
            final fireX = position.x + (60.0 + i * 80.0) * facingDirection;
            final fireY = position.y + size.y / 2 - 20.0;
            game.world.add(
              BossFireLineSegment(
                position: Vector2(fireX, fireY),
                delay: i * 0.08,
              ),
            );
          }
        } else {
          // Charge Dash
          isAttackingPattern = true;
          _specialStateTimer = 0.6;
          velocity.x = CombatConstants.bossDragonDashSpeed * facingDirection;
        }
        break;

      case 't-rex':
        if (activeAttack == 'attack1') {
          // Ground Slam (Shockwave)
          isAttackingPattern = true;
          _specialStateTimer = 0.6;
          // Spawn shockwaves going left and right
          game.world.add(
            BossSeismicShockwave(
              position: Vector2(position.x, position.y + size.y / 2 - 10),
              speed: 250.0,
            ),
          );
          game.world.add(
            BossSeismicShockwave(
              position: Vector2(position.x, position.y + size.y / 2 - 10),
              speed: -250.0,
            ),
          );
          FlameAudio.play('landing.wav', volume: SaveManager.getSfxVolume());
        } else {
          // Rock Throw
          isAttackingPattern = true;
          _specialStateTimer = 0.4;
          final rockPos = Vector2(position.x + 50 * facingDirection, position.y - 20);
          game.world.add(
            BossRockProjectile(
              position: rockPos,
              speed: CombatConstants.bossTRexRockSpeed * facingDirection,
            ),
          );
        }
        break;

      case 'curator':
        if (activeAttack == 'attack1') {
          // Decay Pulse
          isAttackingPattern = true;
          _specialStateTimer = 0.5;
          game.world.add(BossDecayPulse(position: position.clone()));
        } else {
          // Invulnerability
          isInvulnerable = true;
          isAttackingPattern = true;
          _specialStateTimer = CombatConstants.bossCuratorPhaseDuration;
        }
        break;

      case 'shark':
        if (activeAttack == 'attack1') {
          // Water Spread
          isAttackingPattern = true;
          _specialStateTimer = 0.5;
          final spreadAngles = [-0.25, 0.0, 0.25];
          for (var angle in spreadAngles) {
            final velocityVector = Vector2(
              cos(angle) * CombatConstants.bossSharkBladeSpeed * facingDirection,
              sin(angle) * CombatConstants.bossSharkBladeSpeed,
            );
            game.world.add(
              BossWaterBlade(
                position: position.clone(),
                velocity: velocityVector,
              ),
            );
          }
        } else {
          // Lunge Attack
          isAttackingPattern = true;
          _specialStateTimer = 0.6;
          velocity.x = CombatConstants.bossSharkLungeSpeed * facingDirection;
          velocity.y = -220; // Hop in air slightly
        }
        break;

      case 'kitsune':
        if (activeAttack == 'attack1') {
          // Decoy Clones
          isAttackingPattern = true;
          _specialStateTimer = 0.5;
          // Spawn decoy left and right
          game.world.add(BossDecoy(position: Vector2(position.x - 120, position.y), bossType: bossType));
          game.world.add(BossDecoy(position: Vector2(position.x + 120, position.y), bossType: bossType));
        } else {
          // Holo Dash
          isAttackingPattern = true;
          _specialStateTimer = 0.5;
          velocity.x = 350.0 * facingDirection;
          // Spawn trail particles
          for (int i = 0; i < 6; i++) {
            game.world.add(
              ElementParticle(
                position: position.clone(),
                velocity: Vector2(-velocity.x * 0.3 + _rand.nextDouble() * 20, -50 + _rand.nextDouble() * 100),
                color: const Color(0xFF00FFCC),
                radius: 4.0,
                duration: 0.4,
              ),
            );
          }
        }
        break;
    }
  }

  void _updateAttackPattern(double dt) {
    if (bossType.toLowerCase() == 'dragon' && activeAttack == 'attack2') {
      // Dragon Dash: check if hero is touched
      final hero = game.activeHero;
      if (hero.position.distanceTo(position) < 80) {
        hero.takeDamage(CombatConstants.bossDragonDashDamage);
      }
    } else if (bossType.toLowerCase() == 'shark' && activeAttack == 'attack2') {
      // Shark Lunge: check if hero is touched
      final hero = game.activeHero;
      if (hero.position.distanceTo(position) < 85) {
        hero.takeDamage(CombatConstants.bossSharkLungeDamage);
      }
    } else if (bossType.toLowerCase() == 'kitsune' && activeAttack == 'attack2') {
      // Kitsune Holo Strike: check if hero is touched
      final hero = game.activeHero;
      if (hero.position.distanceTo(position) < 80) {
        hero.takeDamage(CombatConstants.bossKitsuneStrikeDamage);
      }
    }
  }

  void _applyGravityAndCollisions(double dt) {
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

      // Skip distant platforms for performance optimization
      if (groundRight < position.x - 400 || groundLeft > position.x + 400) {
        continue;
      }

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

    // Keep horizontal movement active
    position.x += velocity.x * dt;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (isInvulnerable) {
      // Play a block spark/VFX
      for (int i = 0; i < 5; i++) {
        game.world.add(
          ElementParticle(
            position: other.position.clone(),
            velocity: Vector2((_rand.nextDouble() - 0.5) * 150, -50 - _rand.nextDouble() * 100),
            color: const Color(0xFF9400D3),
            radius: 3.0,
            duration: 0.3,
          ),
        );
      }
      return;
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

// ==========================================
// BOSS ATTACK HELPER COMPONENTS
// ==========================================

class BossFireLineSegment extends PositionComponent
    with HasGameReference<VanguardGame>, CollisionCallbacks {
  final double delay;
  double _timer = 0.0;
  bool _spawned = false;

  BossFireLineSegment({
    required super.position,
    required this.delay,
  }) : super(
          size: Vector2(30, 40),
          anchor: Anchor.bottomCenter,
          priority: 4,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (!_spawned && _timer >= delay) {
      _spawned = true;
      add(RectangleHitbox());
    }

    if (_spawned && _timer >= delay + 0.8) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_spawned) return;
    final rect = size.toRect();
    final paint = Paint()
      ..shader = Gradient.linear(
        Offset(size.x / 2, size.y),
        Offset(size.x / 2, 0),
        [const Color(0xFFFF4500), const Color(0xFFFFD700)],
      );
    canvas.drawRect(rect, paint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BaseHero) {
      other.takeDamage(CombatConstants.bossDragonFireLineDamage);
      removeFromParent();
    }
  }
}

class BossRockProjectile extends PositionComponent
    with HasGameReference<VanguardGame>, CollisionCallbacks {
  final double speed;
  double _lifetime = 2.0;

  BossRockProjectile({
    required super.position,
    required this.speed,
  }) : super(
          size: Vector2.all(24),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;
    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF8B5A2B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);

    final border = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, border);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BaseHero) {
      other.takeDamage(CombatConstants.bossTRexRockDamage);
      removeFromParent();
    }
  }
}

class BossSeismicShockwave extends PositionComponent
    with HasGameReference<VanguardGame>, CollisionCallbacks {
  final double speed;
  double _lifetime = 1.2;

  BossSeismicShockwave({
    required super.position,
    required this.speed,
  }) : super(
          size: Vector2(24, 20),
          anchor: Anchor.bottomCenter,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;
    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..shader = Gradient.linear(
        Offset(size.x / 2, size.y),
        Offset(size.x / 2, 0),
        [const Color(0xFFFFD700), Colors.transparent],
      );
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BaseHero) {
      other.takeDamage(CombatConstants.bossTRexSlamDamage);
      removeFromParent();
    }
  }
}

class BossDecayPulse extends PositionComponent
    with HasGameReference<VanguardGame>, CollisionCallbacks {
  double _radius = 10.0;
  final double _maxRadius = 140.0;
  bool _hasHit = false;

  BossDecayPulse({
    required super.position,
  }) : super(
          size: Vector2.all(280),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: _radius, position: size / 2 - Vector2.all(_radius)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _radius += 200 * dt;
    if (_radius >= _maxRadius) {
      removeFromParent();
    } else {
      // Re-create hitbox to fit expanding radius
      children.whereType<CircleHitbox>().firstOrNull?.removeFromParent();
      add(CircleHitbox(radius: _radius, position: size / 2 - Vector2.all(_radius)));
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final paint = Paint()
      ..color = const Color(0xFF9400D3).withValues(alpha: (1.0 - (_radius / _maxRadius)).clamp(0.0, 1.0))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, _radius, paint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BaseHero && !_hasHit) {
      _hasHit = true;
      other.takeDamage(CombatConstants.bossCuratorDecayDamage);
    }
  }
}

class BossWaterBlade extends PositionComponent
    with HasGameReference<VanguardGame>, CollisionCallbacks {
  final Vector2 velocity;
  double _lifetime = 1.0;

  BossWaterBlade({
    required super.position,
    required this.velocity,
  }) : super(
          size: Vector2(25, 12),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    angle = atan2(velocity.y, velocity.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF1E90FF)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.y / 2)
      ..lineTo(size.x, 0)
      ..lineTo(size.x * 0.7, size.y / 2)
      ..lineTo(size.x, size.y)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BaseHero) {
      other.takeDamage(CombatConstants.bossSharkSpreadDamage);
      removeFromParent();
    }
  }
}

class BossDecoy extends PositionComponent with HasGameReference<VanguardGame> {
  final String bossType;
  double _lifetime = CombatConstants.bossKitsuneDecoyDuration;
  final Random _rand = Random();
  double _moveTimer = 0.0;
  double _vx = 60.0;

  BossDecoy({
    required super.position,
    required this.bossType,
  }) : super(
          size: Vector2.all(192),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
      return;
    }

    _moveTimer -= dt;
    if (_moveTimer <= 0) {
      _vx = (_rand.nextBool() ? 1 : -1) * 80.0;
      _moveTimer = 0.8;
    }

    position.x += _vx * dt;
    if (_vx < 0 && scale.x > 0) scale.x = -1;
    if (_vx > 0 && scale.x < 0) scale.x = 1;

    // Apply holographic flickering
    final wave = 0.3 + 0.3 * sin(_lifetime * 16);
    paint.color = Colors.cyan.withValues(alpha: wave);
  }

  @override
  void render(Canvas canvas) {
    // Render a placeholder holographic outline representing the kitsune boss
    final paintObj = Paint()
      ..color = const Color(0xFF00FFCC).withValues(alpha: paint.color.a)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRect(size.toRect().deflate(10), paintObj);
  }
}
