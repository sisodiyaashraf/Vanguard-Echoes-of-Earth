import 'dart:ui';
import 'package:flame/components.dart';

class ElementParticle extends PositionComponent with HasPaint {
  final Vector2 velocity;
  final Color color;
  final double radius;
  double lifeTime;
  final double maxLifeTime;

  ElementParticle({
    required super.position,
    required this.velocity,
    required this.color,
    this.radius = 4.0,
    double duration = 0.5,
  })  : lifeTime = duration,
        maxLifeTime = duration;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
    } else {
      final opacity = (lifeTime / maxLifeTime).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: opacity * 0.7);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final sizeRatio = (lifeTime / maxLifeTime);
    canvas.drawCircle(Offset.zero, radius * sizeRatio, paint);
  }
}
