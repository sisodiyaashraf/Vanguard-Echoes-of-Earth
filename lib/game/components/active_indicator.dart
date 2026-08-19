import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ActiveIndicator extends PositionComponent {
  ActiveIndicator() : super(size: Vector2(16, 16));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Glowing cyan/teal paint
    final paint = Paint()
      ..color = const Color(0xFF00FFCC)
      ..style = PaintingStyle.fill;

    // Draw a neat downward pointing arrow/pointer
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(8, -12)
      ..lineTo(3, -12)
      ..lineTo(3, -20)
      ..lineTo(-3, -20)
      ..lineTo(-3, -12)
      ..lineTo(-8, -12)
      ..close();

    canvas.drawPath(path, paint);

    // White outline for definition
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, borderPaint);
  }
}
