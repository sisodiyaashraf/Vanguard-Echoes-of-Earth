import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DustParticle extends PositionComponent with HasPaint {
  final Vector2 velocity;
  double lifeTime = 0.4;
  final double maxLifeTime = 0.4;

  DustParticle({
    required super.position,
    required this.velocity,
  }) {
    paint.color = Colors.white70;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
    } else {
      final opacity = (lifeTime / maxLifeTime).clamp(0.0, 1.0);
      paint.color = Colors.white.withValues(alpha: opacity * 0.5);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final radius = 5.0 * (lifeTime / maxLifeTime);
    canvas.drawCircle(Offset.zero, radius, paint);
  }
}
