import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:vanguard_echoes_of_earth/game/core/physics_constants.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/plasma_shockwave.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/hero_stats.dart';

enum HeroState { idle, run, jump, attack }

class DragonHero extends SpriteAnimationGroupComponent<HeroState>
    with HasGameReference<VanguardGame>, KeyboardHandler {
  final Vector2 velocity = Vector2.zero();
  double horizontalInput = 0.0;
  bool isGrounded = false;

  // Stats & Regen
  final HeroStats stats = HeroStats();
  double _regenAccumulator = 0.0;

  // Combat state variables
  double _attackTimeRemaining = 0.0;
  double _plasmaCooldownRemaining = 0.0;

  bool get isAttacking => _attackTimeRemaining > 0.0;
  double get plasmaCooldownRemaining => _plasmaCooldownRemaining;

  DragonHero({
    super.position,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2.all(128);
    anchor = Anchor.center;

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
        stepTime: CombatConstants.meleeAttackDuration / 3,
        textureSize: Vector2.all(128),
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
  void update(double dt) {
    super.update(dt);

    // Decrement combat timers
    _updateTimers(dt);

    // Passive energy regen (5 energy per second)
    _regenAccumulator += dt;
    if (_regenAccumulator >= 1.0) {
      stats.regenEnergy(5);
      _regenAccumulator -= 1.0;
    }

    // Apply gravity
    velocity.y += PhysicsConstants.gravity * dt;

    // Lock horizontal speed during basic attack animation
    final effectiveHorizontalInput = isAttacking ? 0.0 : horizontalInput;
    
    position.x += effectiveHorizontalInput * PhysicsConstants.moveSpeed * dt;
    position.y += velocity.y * dt;

    // Collision detection with Ground component
    final halfHeight = size.y / 2;
    final halfWidth = size.x / 2;
    final ground = game.ground;
    final groundTop = ground.position.y;
    final groundLeft = ground.position.x;
    final groundRight = ground.position.x + ground.size.x;

    // Check if the hero overlaps horizontally with the platform
    if (position.x + halfWidth > groundLeft && position.x - halfWidth < groundRight) {
      if (velocity.y >= 0 &&
          position.y + halfHeight >= groundTop &&
          position.y + halfHeight - velocity.y * dt <= groundTop + 10) {
        position.y = groundTop - halfHeight;
        velocity.y = 0;
        isGrounded = true;
      }
    } else {
      isGrounded = false;
    }

    // Safety check: if hero falls off the platform, reset
    if (position.y > groundTop + 400 || position.y > game.size.y + 100) {
      resetPosition();
    }

    // Flip sprite scale horizontally based on movement direction (only when not attacking)
    if (!isAttacking) {
      if (horizontalInput < 0 && scale.x > 0) {
        scale.x = -1;
      } else if (horizontalInput > 0 && scale.x < 0) {
        scale.x = 1;
      }
    }

    // Choose active animation state
    _updateAnimationState(effectiveHorizontalInput);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // If melee attack is currently active, lock movement input
    if (isAttacking) {
      horizontalInput = 0.0;
      return true;
    }

    // Reset horizontal movement input
    horizontalInput = 0.0;

    // Check directional keys
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      horizontalInput -= 1.0;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      horizontalInput += 1.0;
    }

    // Check jump command
    final isJumpPressed = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);

    if (isJumpPressed && isGrounded) {
      velocity.y = PhysicsConstants.jumpVelocity;
      isGrounded = false;
    }

    // Check basic attack commands
    if (keysPressed.contains(LogicalKeyboardKey.keyF) ||
        keysPressed.contains(LogicalKeyboardKey.keyJ)) {
      _meleeAttack();
    }

    // Check plasma shockwave command
    if (keysPressed.contains(LogicalKeyboardKey.keyK)) {
      _firePlasmaShockwave();
    }

    // Check debug takeDamage command
    if (event is KeyDownEvent && keysPressed.contains(LogicalKeyboardKey.keyH)) {
      stats.takeDamage(10);
    }

    return true;
  }

  void resetPosition() {
    position = Vector2(200, 100);
    velocity.setZero();
    isGrounded = false;
    _attackTimeRemaining = 0.0;
    _plasmaCooldownRemaining = 0.0;
  }

  // Private Combat Helper Methods

  void _updateTimers(double dt) {
    if (_attackTimeRemaining > 0.0) {
      _attackTimeRemaining -= dt;
      if (_attackTimeRemaining < 0.0) {
        _attackTimeRemaining = 0.0;
      }
    }

    if (_plasmaCooldownRemaining > 0.0) {
      _plasmaCooldownRemaining -= dt;
      if (_plasmaCooldownRemaining < 0.0) {
        _plasmaCooldownRemaining = 0.0;
      }
    }
  }

  void _meleeAttack() {
    if (isAttacking) return;
    _attackTimeRemaining = CombatConstants.meleeAttackDuration;
    current = HeroState.attack;
    animationTicker?.reset();
  }

  void _firePlasmaShockwave() {
    if (_plasmaCooldownRemaining > 0.0) return;

    // Check and spend energy
    if (!stats.spendEnergy(25)) return;

    // Spawn shockwave in front of Dragon based on facing direction (scale.x.sign)
    final direction = scale.x.sign;
    final spawnOffset = Vector2(direction * 80.0, 0.0);
    final spawnPos = position + spawnOffset;

    final shockwave = PlasmaShockwave(
      direction: direction,
      spawnPosition: spawnPos,
    );

    game.world.add(shockwave);

    _plasmaCooldownRemaining = CombatConstants.plasmaCooldown;
  }

  void _updateAnimationState(double currentHorizontalInput) {
    if (isAttacking) {
      current = HeroState.attack;
    } else if (!isGrounded) {
      current = HeroState.jump;
    } else if (currentHorizontalInput != 0.0) {
      current = HeroState.run;
    } else {
      current = HeroState.idle;
    }
  }
}
