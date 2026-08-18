import 'dart:ui';
import 'package:flame/components.dart';

class Ground extends PositionComponent {
  Ground({
    super.position,
    super.size,
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

    // Draw neon gradient top border
    final borderPaint = Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(size.x, 0),
        [
          const Color(0xFF00F2FE), // Bright Neon Cyan
          const Color(0xFF4FACFE), // Vibrant Neon Blue
        ],
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
