import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:vanguard_echoes_of_earth/game/core/physics_constants.dart';
import 'package:vanguard_echoes_of_earth/game/core/hero_stats.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';

enum HeroState { idle, run, jump, attack, superpower, transformation }

abstract class BaseHero extends SpriteAnimationGroupComponent<HeroState>
    with HasGameReference<VanguardGame>, KeyboardHandler {
  final Vector2 velocity = Vector2.zero();
  double horizontalInput = 0.0;
  bool isGrounded = false;

  // Stats & Regen
  final HeroStats stats = HeroStats();
  double _regenAccumulator = 0.0;

  // Active status for switching input gating
  bool isActive = false;

  // Combat/State variables
  double _attackTimeRemaining = 0.0;
  double _powerCooldownRemaining = 0.0;
  double _superpowerTimeRemaining = 0.0;
  double _transformationTimeRemaining = 0.0;

  bool get isAttacking => _attackTimeRemaining > 0.0;
  double get powerCooldownRemaining => _powerCooldownRemaining;
  bool get isSuperpowerActive => _superpowerTimeRemaining > 0.0;
  bool get isTransforming => _transformationTimeRemaining > 0.0;

  // Abstract getters/methods for subclasses
  double get meleeAttackDuration;
  double get powerCooldown;
  int get powerEnergyCost;
  void spawnPower();

  BaseHero({
    super.position,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(128);
    anchor = Anchor.center;
  }

  // Helper utility to load horizontal animation sheets of varying dimensions
  Future<SpriteAnimation> loadHorizontalAnimation(
    String fileName,
    int frameCount,
    double stepTime, {
    bool loop = false,
  }) async {
    try {
      final image = await game.images.load(fileName);
      final frameWidth = image.width / frameCount;
      final frameHeight = image.height.toDouble();
      
      final sprites = List.generate(frameCount, (i) {
        return Sprite(
          image,
          srcPosition: Vector2(i * frameWidth, 0),
          srcSize: Vector2(frameWidth, frameHeight),
        );
      });
      return SpriteAnimation.spriteList(sprites, stepTime: stepTime, loop: loop);
    } catch (e, stack) {
      // ignore: avoid_print
      print('ERROR: Failed to load animation sheet "$fileName". Details: $e');
      // ignore: avoid_print
      print(stack);
      rethrow;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Decrement combat and state timers
    _updateTimers(dt);

    // Passive energy regen (5 energy per second)
    _regenAccumulator += dt;
    if (_regenAccumulator >= 1.0) {
      stats.regenEnergy(5);
      _regenAccumulator -= 1.0;
    }

    // Apply gravity
    velocity.y += PhysicsConstants.gravity * dt;

    // Lock horizontal speed during basic attack, power casting, or transformation
    final isLocked = isAttacking || isSuperpowerActive || isTransforming;
    final effectiveHorizontalInput = isLocked ? 0.0 : horizontalInput;
    
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

    // Flip sprite scale horizontally based on movement direction (only when not in locked states)
    if (!isLocked) {
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
    // If this hero is not active, do not process input
    if (!isActive) return false;

    // If locked in action, ignore movement keys but consume input
    if (isAttacking || isSuperpowerActive || isTransforming) {
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

    // Check basic melee attack commands
    if (keysPressed.contains(LogicalKeyboardKey.keyF) ||
        keysPressed.contains(LogicalKeyboardKey.keyJ)) {
      _meleeAttack();
    }

    // Check power commands (key K)
    if (keysPressed.contains(LogicalKeyboardKey.keyK)) {
      _firePower();
    }

    // Check transformation command (key T)
    if (keysPressed.contains(LogicalKeyboardKey.keyT)) {
      _transform();
    }

    // Check debug takeDamage command (key H)
    if (event is KeyDownEvent && keysPressed.contains(LogicalKeyboardKey.keyH)) {
      stats.takeDamage(10);
    }

    return true;
  }

  void _transform() {
    if (isTransforming || isSuperpowerActive || isAttacking) return;
    if (animations?[HeroState.transformation] != null) {
      _transformationTimeRemaining = 0.60; // 4 frames at 0.15s
      current = HeroState.transformation;
      animationTicker?.reset();
    }
  }

  void resetPosition() {
    position = Vector2(200, 100);
    velocity.setZero();
    isGrounded = false;
    _attackTimeRemaining = 0.0;
    _powerCooldownRemaining = 0.0;
    _superpowerTimeRemaining = 0.0;
    _transformationTimeRemaining = 0.0;
  }

  // Combat Helper Methods

  void _updateTimers(double dt) {
    if (_attackTimeRemaining > 0.0) {
      _attackTimeRemaining -= dt;
      if (_attackTimeRemaining < 0.0) {
        _attackTimeRemaining = 0.0;
      }
    }

    if (_powerCooldownRemaining > 0.0) {
      _powerCooldownRemaining -= dt;
      if (_powerCooldownRemaining < 0.0) {
        _powerCooldownRemaining = 0.0;
      }
    }

    if (_superpowerTimeRemaining > 0.0) {
      _superpowerTimeRemaining -= dt;
      if (_superpowerTimeRemaining < 0.0) {
        _superpowerTimeRemaining = 0.0;
      }
    }

    if (_transformationTimeRemaining > 0.0) {
      _transformationTimeRemaining -= dt;
      if (_transformationTimeRemaining < 0.0) {
        _transformationTimeRemaining = 0.0;
      }
    }
  }

  void _meleeAttack() {
    if (isAttacking) return;
    _attackTimeRemaining = meleeAttackDuration;
    current = HeroState.attack;
    animationTicker?.reset();
  }

  void _firePower() {
    if (_powerCooldownRemaining > 0.0) return;

    // Check and spend energy
    if (!stats.spendEnergy(powerEnergyCost)) return;

    spawnPower();

    _superpowerTimeRemaining = 0.45; // 3 frames * 0.15s = 0.45s
    current = HeroState.superpower;
    animationTicker?.reset();

    _powerCooldownRemaining = powerCooldown;
  }

  void _updateAnimationState(double currentHorizontalInput) {
    if (isTransforming) {
      current = HeroState.transformation;
    } else if (isSuperpowerActive) {
      current = HeroState.superpower;
    } else if (isAttacking) {
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
