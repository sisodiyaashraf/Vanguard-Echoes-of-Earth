import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:vanguard_echoes_of_earth/game/core/physics_constants.dart';
import 'package:vanguard_echoes_of_earth/game/core/hero_stats.dart';
import 'package:vanguard_echoes_of_earth/game/core/hero_input_state.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/components/dust_particle.dart';
import 'package:vanguard_echoes_of_earth/game/components/melee_strike.dart';
import 'package:vanguard_echoes_of_earth/game/components/platform.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';

enum HeroState { idle, run, jump, attack, superpower, transformation }

abstract class BaseHero extends SpriteAnimationGroupComponent<HeroState>
    with HasGameReference<VanguardGame>, KeyboardHandler {
  final Vector2 velocity = Vector2.zero();
  final HeroInputState inputState = HeroInputState();
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
  double _meleeHitboxDelay = 0.0;

  // Synergy tracking
  DateTime? lastPowerUsedTime;

  // Setter for synergy combo cooldown
  set powerCooldownRemainingValue(double val) => _powerCooldownRemaining = val;

  // Coyote time & input buffering
  double _coyoteTimeRemaining = 0.0;
  double _jumpBufferTimeRemaining = 0.0;

  // Landing squash effect
  double _squashTimer = 0.0;

  // Running dust particles
  double _dustTimer = 0.0;
  final Random _random = Random();

  // Hit-flash effect
  double _hitFlashTimer = 0.0;

  bool get isAttacking => _attackTimeRemaining > 0.0;
  double get powerCooldownRemaining => _powerCooldownRemaining;
  bool get isSuperpowerActive => _superpowerTimeRemaining > 0.0;
  bool get isTransforming => _transformationTimeRemaining > 0.0;

  // Abstract getters/methods for subclasses
  String get heroName;
  double get meleeAttackDuration;
  double get basePowerCooldown;
  int get powerEnergyCost;
  double get groundContactOffset;
  void spawnPower();

  double get powerCooldown {
    double cd = basePowerCooldown;
    final cleanName = heroName.toLowerCase();
    if (hasSkillUnlocked('${cleanName}_faster_cooldown') ||
        hasSkillUnlocked('${cleanName}_temporal_flow') ||
        hasSkillUnlocked('${cleanName}_rapid_agility') ||
        hasSkillUnlocked('${cleanName}_trickster_cd')) {
      cd *= 0.85;
    }
    return cd;
  }

  BaseHero({
    super.position,
  });

  @override
  Future<void> onLoad() async {
    priority = 3;
    await super.onLoad();
    size = Vector2.all(128);
    anchor = Anchor.center;

    applyProgressStats();

    // Add central hitbox for receiving enemy contact damage
    add(RectangleHitbox(
      size: Vector2(40, 90),
      position: Vector2(44, 19),
    ));
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
    final wasGroundedBefore = isGrounded;

    super.update(dt);

    // Decrement combat and state timers
    _updateTimers(dt);

    // Melee hitbox delay handler
    if (_meleeHitboxDelay > 0.0) {
      _meleeHitboxDelay -= dt;
      if (_meleeHitboxDelay <= 0.0) {
        _meleeHitboxDelay = 0.0;
        final direction = scale.x.sign;
        final strikeSize = Vector2(80, 80);
        final strikePos = position + Vector2(direction * 60, 0);
        final strike = MeleeStrike(
          position: strikePos,
          size: strikeSize,
        );
        game.world.add(strike);
      }
    }

    // Passive energy regen (5 energy per second)
    _regenAccumulator += dt;
    if (_regenAccumulator >= 1.0) {
      stats.regenEnergy(5);
      _regenAccumulator -= 1.0;
    }

    // Gate all input if dialogue overlay is active
    if (game.isInputGated) {
      inputState.reset();
    }

    final isLocked = isAttacking || isSuperpowerActive || isTransforming;

    // Read and consume input triggers if not gated/locked
    if (!game.isInputGated && !isLocked) {
      if (inputState.jumpPressed) {
        inputState.jumpPressed = false;
        if (isGrounded || _coyoteTimeRemaining > 0.0) {
          velocity.y = PhysicsConstants.jumpVelocity;
          isGrounded = false;
          _coyoteTimeRemaining = 0.0;
          _jumpBufferTimeRemaining = 0.0;
          FlameAudio.play('jump.wav', volume: SaveManager.getSfxVolume());
        } else {
          _jumpBufferTimeRemaining = 0.1;
        }
      }

      if (inputState.attackPressed) {
        inputState.attackPressed = false;
        _meleeAttack();
      }

      if (inputState.powerPressed) {
        inputState.powerPressed = false;
        _firePower();
      }
    } else {
      // Clear triggers if we are locked or input is gated
      inputState.resetTriggers();
    }

    final effectiveHorizontalInput = (isLocked || game.isInputGated) ? 0.0 : inputState.moveX;
    
    // Horizontal Movement Acceleration & Deceleration (Friction)
    if (effectiveHorizontalInput != 0.0) {
      velocity.x = effectiveHorizontalInput * PhysicsConstants.moveSpeed;
    } else {
      const double lerpFactor = 12.0;
      velocity.x = velocity.x * (1.0 - lerpFactor * dt).clamp(0.0, 1.0);
      if (velocity.x.abs() < 1.0) {
        velocity.x = 0.0;
      }
    }

    // Gravity and max fall clamp
    if (!isGrounded) {
      velocity.y += PhysicsConstants.gravity * dt;
    }
    velocity.y = velocity.y.clamp(-1000.0, 700.0);

    position.x += velocity.x * dt;
    position.y += velocity.y * dt;

    // Collision detection with Platform components
    final halfHeight = size.y / 2;
    final halfWidth = size.x / 2;
    final platforms = game.world.children.whereType<Platform>();
    bool onAnyPlatform = false;
    for (var platform in platforms) {
      final groundTop = platform.position.y;
      final groundLeft = platform.position.x;
      final groundRight = platform.position.x + platform.size.x;

      // Skip distant platforms for performance optimization
      if (groundRight < position.x - 600 || groundLeft > position.x + 600) {
        continue;
      }

      if (position.x + halfWidth > groundLeft && position.x - halfWidth < groundRight) {
        if (isGrounded && velocity.y == 0) {
          position.y = groundTop - halfHeight + groundContactOffset;
          onAnyPlatform = true;
          break;
        }

        final visualFeetY = position.y + halfHeight - groundContactOffset;
        if (velocity.y >= 0 &&
            visualFeetY >= groundTop &&
            visualFeetY - velocity.y * dt <= groundTop + 10) {
          position.y = groundTop - halfHeight + groundContactOffset;
          velocity.y = 0;
          isGrounded = true;
          onAnyPlatform = true;
          break;
        }
      }
    }
    if (!onAnyPlatform) {
      isGrounded = false;
    }

    // Trigger landing squash micro-animation on transition from air to ground
    if (!wasGroundedBefore && isGrounded) {
      _squashTimer = 0.15;
      FlameAudio.play('landing.wav', volume: SaveManager.getSfxVolume());
    }

    // Manage Coyote Time
    if (isGrounded) {
      _coyoteTimeRemaining = 0.1;
    } else {
      _coyoteTimeRemaining = max(0.0, _coyoteTimeRemaining - dt);
    }

    // Manage Jump Input Buffering
    if (_jumpBufferTimeRemaining > 0.0) {
      _jumpBufferTimeRemaining = max(0.0, _jumpBufferTimeRemaining - dt);
      if (isGrounded && _jumpBufferTimeRemaining > 0.0) {
        velocity.y = PhysicsConstants.jumpVelocity;
        isGrounded = false;
        _jumpBufferTimeRemaining = 0.0;
        FlameAudio.play('jump.wav', volume: SaveManager.getSfxVolume());
      }
    }

    // Procedural Landing Squash scaling
    if (_squashTimer > 0.0) {
      _squashTimer = max(0.0, _squashTimer - dt);
      final squashFactor = 0.12 * sin(pi * _squashTimer / 0.15);
      scale.y = 1.0 - squashFactor;
      scale.x = scale.x.sign * (1.0 + squashFactor * 0.7);
    } else {
      scale.y = 1.0;
      scale.x = scale.x.sign * 1.0;
    }

    // Run footstep dust particles
    if (current == HeroState.run && isGrounded) {
      _dustTimer += dt;
      if (_dustTimer >= 0.15) {
        _dustTimer = 0.0;
        final currentDust = game.world.children.whereType<DustParticle>().length;
        if (currentDust < 20) {
          final spawnPos = position + Vector2(-scale.x.sign * 15.0, size.y / 2 - 5);
          final randomX = (_random.nextDouble() - 0.5) * 15 - scale.x.sign * 35;
          final randomY = -_random.nextDouble() * 15 - 5;
          game.world.add(DustParticle(
            position: spawnPos,
            velocity: Vector2(randomX, randomY),
          ));
        }
      }
    }

    // Hit-flash effect
    if (_hitFlashTimer > 0) {
      _hitFlashTimer = max(0.0, _hitFlashTimer - dt);
      final tick = (_hitFlashTimer * 20).toInt();
      paint.colorFilter = tick % 2 == 0
          ? const ColorFilter.mode(Colors.white, BlendMode.srcATop)
          : const ColorFilter.mode(Color(0xFFFF3333), BlendMode.srcATop);
      if (_hitFlashTimer <= 0.0) {
        paint.colorFilter = null;
      }
    }

    // Safety check: if hero falls off the platform, reset
    if (position.y > 800) {
      resetPosition();
    }

    // Flip sprite scale horizontally based on movement direction (only when not in locked states)
    if (!isLocked) {
      if (effectiveHorizontalInput < 0 && scale.x > 0) {
        scale.x = -1;
      } else if (effectiveHorizontalInput > 0 && scale.x < 0) {
        scale.x = 1;
      }
    }

    // Choose active animation state
    _updateAnimationState(effectiveHorizontalInput);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // If dialogue overlay is active, gate all movement/actions
    if (game.isInputGated) {
      inputState.reset();
      return true;
    }

    // If this hero is not active, do not process input
    if (!isActive) return false;

    // If locked in action, ignore movement keys but consume input
    if (isAttacking || isSuperpowerActive || isTransforming) {
      inputState.keyboardMoveX = 0.0;
      return true;
    }

    // Reset keyboard movement input
    inputState.keyboardMoveX = 0.0;

    // Check directional keys
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      inputState.keyboardMoveX -= 1.0;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      inputState.keyboardMoveX += 1.0;
    }

    // Check action commands on KeyDownEvent to trigger only once per press
    if (event is KeyDownEvent) {
      final isJumpPressed = keysPressed.contains(LogicalKeyboardKey.space) ||
          keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW);

      if (isJumpPressed) {
        inputState.jumpPressed = true;
      }

      if (keysPressed.contains(LogicalKeyboardKey.keyF) ||
          keysPressed.contains(LogicalKeyboardKey.keyJ)) {
        inputState.attackPressed = true;
      }

      if (keysPressed.contains(LogicalKeyboardKey.keyK)) {
        inputState.powerPressed = true;
      }

      // Check transformation command (key T)
      if (keysPressed.contains(LogicalKeyboardKey.keyT)) {
        _transform();
      }
    }

    return true;
  }

  void takeDamage(int amount) {
    stats.takeDamage(amount);
    game.hasTakenDamageThisLevel = true;
    _hitFlashTimer = 0.15;
    FlameAudio.play('hero_hurt.wav', volume: SaveManager.getSfxVolume());

    if (stats.currentHealth <= 0) {
      game.triggerGameOver();
    }
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
    _meleeHitboxDelay = 0.0;
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
      if (_transformationTimeRemaining <= 0.0) {
        _transformationTimeRemaining = 0.0;
        // Zoom camera back out
        game.isCameraCutsceneActive = true;
        game.cameraCutsceneTimer = 0.0;
        game.cameraCutsceneZoomStart = 1.5;
        game.cameraCutsceneZoomEnd = 1.0;
        game.cameraCutscenePanStart = Vector2.zero();
        game.cameraCutscenePanEnd = Vector2.zero();
      }
    }
  }

  void _meleeAttack() {
    if (isAttacking) return;
    _attackTimeRemaining = meleeAttackDuration;
    current = HeroState.attack;
    animationTicker?.reset();
    _meleeHitboxDelay = 0.12; // Spawn hitbox at impact frame
  }

  void _firePower() {
    if (_powerCooldownRemaining > 0.0) return;

    // Check synergy combo
    if (game.isComboAvailable()) {
      game.triggerSynergyCombo();
      return;
    }

    // Check and spend energy
    if (!stats.spendEnergy(powerEnergyCost)) return;

    lastPowerUsedTime = DateTime.now();
    game.hasUsedPowerThisLevel = true;
    spawnPower();
    FlameAudio.play('power.wav', volume: SaveManager.getSfxVolume());

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

  void triggerTransformation() {
    if (animations?[HeroState.transformation] != null) {
      _transformationTimeRemaining = 0.60;
      current = HeroState.transformation;
      animationTicker?.reset();
    }
  }

  void applyProgressStats() {
    final heroProgress = SaveManager.getHeroProgress(heroName);
    
    // Apply level upgrades (starts at level 1, so level - 1 upgrades)
    final levelBonus = (heroProgress.level - 1) * 5;
    
    // Apply skill buffs
    int skillHealthBonus = 0;
    int skillEnergyBonus = 0;
    
    final cleanName = heroName.toLowerCase();
    if (hasSkillUnlocked('${cleanName}_thicker_scales') ||
        hasSkillUnlocked('${cleanName}_unbreakable_guard') ||
        hasSkillUnlocked('${cleanName}_nanotech_shield') ||
        hasSkillUnlocked('${cleanName}_neon_evasion')) {
      skillHealthBonus = 10;
      if (cleanName == 't-rex' || cleanName == 'kitsune') {
        skillHealthBonus = 15;
      }
    }
    if (hasSkillUnlocked('${cleanName}_rage_energy') ||
        hasSkillUnlocked('${cleanName}_deep_lung')) {
      skillEnergyBonus = 20;
    }
    
    stats.upgradeStats(levelBonus + skillHealthBonus, levelBonus + skillEnergyBonus);
    stats.reset();
  }

  bool hasSkillUnlocked(String skillId) {
    final prog = SaveManager.getHeroProgress(heroName);
    return prog.unlockedSkillIds.contains(skillId);
  }

  void onLevelUp() {
    stats.upgradeStats(5, 5);
    stats.reset();
    
    game.world.add(
      LevelUpText(position: position.clone() - Vector2(0, size.y / 2)),
    );
    
    FlameAudio.play('win.wav', volume: SaveManager.getSfxVolume() * 0.7);
  }
}

class LevelUpText extends TextComponent with HasGameReference<VanguardGame> {
  double _elapsed = 0.0;
  
  LevelUpText({required super.position}) : super(
    text: 'LEVEL UP!',
    textRenderer: TextPaint(
      style: TextStyle(
        color: const Color(0xFF00FFCC),
        fontSize: SaveManager.isLargerText() ? 22.0 : 16.0,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 4.0, offset: Offset(2.0, 2.0)),
        ],
      ),
    ),
    anchor: Anchor.center,
    priority: 5,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    position.y -= 40 * dt;
    _elapsed += dt;
    if (_elapsed >= 1.5) {
      removeFromParent();
    } else {
      final double progress = (_elapsed / 1.5).clamp(0.0, 1.0);
      final alpha = (255 * (1.0 - progress)).toInt();
      textRenderer = TextPaint(
        style: TextStyle(
          color: const Color(0xFF00FFCC).withAlpha(alpha),
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black.withAlpha(alpha), blurRadius: 4.0, offset: const Offset(2.0, 2.0)),
          ],
        ),
      );
    }
  }
}
