import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:vanguard_echoes_of_earth/game/core/physics_constants.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';

enum HeroState { idle, run, jump }

class DragonHero extends SpriteAnimationGroupComponent<HeroState>
    with HasGameReference<VanguardGame>, KeyboardHandler {
  final Vector2 velocity = Vector2.zero();
  double horizontalInput = 0.0;
  bool isGrounded = false;

  DragonHero({
    super.position,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2.all(64);
    anchor = Anchor.center;

    // Load animations using sequenced frame data (each frame is 64x64px layout horizontally)
    final idleAnimation = await game.loadSpriteAnimation(
      'dragon_idle.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.15,
        textureSize: Vector2.all(64),
      ),
    );

    final runAnimation = await game.loadSpriteAnimation(
      'dragon_run.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.10,
        textureSize: Vector2.all(64),
      ),
    );

    final jumpAnimation = await game.loadSpriteAnimation(
      'dragon_jump.png',
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.20,
        textureSize: Vector2.all(64),
      ),
    );

    animations = {
      HeroState.idle: idleAnimation,
      HeroState.run: runAnimation,
      HeroState.jump: jumpAnimation,
    };

    current = HeroState.idle;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity
    velocity.y += PhysicsConstants.gravity * dt;

    // Move hero position
    position.x += horizontalInput * PhysicsConstants.moveSpeed * dt;
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
      // Landing: Check if hero is moving down and crosses ground threshold
      if (velocity.y >= 0 &&
          position.y + halfHeight >= groundTop &&
          position.y + halfHeight - velocity.y * dt <= groundTop + 10) {
        position.y = groundTop - halfHeight;
        velocity.y = 0;
        isGrounded = true;
      }
    } else {
      // Hero has walked off the side of the platform
      isGrounded = false;
    }

    // Safety check: if hero falls off the platform / screen, reset
    if (position.y > groundTop + 400 || position.y > game.size.y + 100) {
      resetPosition();
    }

    // Flip sprite scale horizontally based on horizontal velocity / input direction
    if (horizontalInput < 0 && scale.x > 0) {
      scale.x = -1;
    } else if (horizontalInput > 0 && scale.x < 0) {
      scale.x = 1;
    }

    // Choose active animation state
    if (!isGrounded) {
      current = HeroState.jump;
    } else if (horizontalInput != 0) {
      current = HeroState.run;
    } else {
      current = HeroState.idle;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
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

    return true;
  }

  void resetPosition() {
    position = Vector2(200, 100);
    velocity.setZero();
    isGrounded = false;
  }
}
