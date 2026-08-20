import 'dart:ui';
import 'package:flame/components.dart';

class Platform extends PositionComponent {
  final bool isBreakable;

  Platform({
    super.position,
    super.size,
    this.isBreakable = false,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw platform background
    final rect = size.toRect();
    final backgroundPaint = Paint()
      ..color = const Color(0xFF1E222B)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, backgroundPaint);

    // Draw neon border: cyan for normal, red-orange for breakable
    final Color startColor = isBreakable ? const Color(0xFFFF5722) : const Color(0xFF00F2FE);
    final Color endColor = isBreakable ? const Color(0xFFE53935) : const Color(0xFF4FACFE);

    final borderPaint = Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(size.x, 0),
        [startColor, endColor],
      )
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset.zero,
      Offset(size.x, 0),
      borderPaint,
    );
  }
}
