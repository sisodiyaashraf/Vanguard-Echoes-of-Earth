import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'dart:ui';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class PlasmaShockwave extends PositionComponent {
  final double direction; // +1.0 for right, -1.0 for left
  double lifeTime = 0.0;

  PlasmaShockwave({
    required this.direction,
    required Vector2 spawnPosition,
  }) : super(
          position: spawnPosition,
          size: Vector2(32, 40),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Flip the entire component horizontally if facing left
    scale.x = direction;

    // Add rectangle hitbox for future collision detection
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move forward in the direction faced
    position.x += direction * CombatConstants.plasmaSpeed * dt;

    // Increment lifetime and remove from parent when expired
    lifeTime += dt;
    if (lifeTime >= CombatConstants.plasmaLifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Create a smooth glowing neon plasma fill
    final fillPaint = Paint()
      ..shader = Gradient.radial(
        Offset(size.x / 2, size.y / 2),
        size.x / 2,
        [
          const Color(0xFFFFEB3B), // White-Hot Yellow center
          const Color(0xFFFF5722), // Deep Neon Orange
          const Color(0x00FF5722), // Fade to transparent
        ],
        [0.0, 0.7, 1.0],
      )
      ..style = PaintingStyle.fill;

    // Draw crescent crescent wave facing right (direction scale handles left flips)
    final crescentPath = Path()
      ..moveTo(size.x * 0.1, 0)
      ..quadraticBezierTo(size.x * 0.9, size.y * 0.5, size.x * 0.1, size.y)
      ..quadraticBezierTo(size.x * 0.5, size.y * 0.5, size.x * 0.1, 0)
      ..close();

    canvas.drawPath(crescentPath, fillPaint);

    // Neon edge highlight
    final strokePaint = Paint()
      ..color = const Color(0xFFFF8F00)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(crescentPath, strokePaint);
  }
}
