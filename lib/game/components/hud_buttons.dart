import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show TextStyle, FontWeight;

class RoundIconButton extends PositionComponent {
  final Sprite sprite;
  final double radius;
  final Color backgroundColor;

  RoundIconButton({
    required this.sprite,
    this.radius = 30,
    required this.backgroundColor,
  }) : super(size: Vector2.all(radius * 2));

  @override
  Future<void> onLoad() async {
    // Semi-transparent background circle
    final bg = CircleComponent(
      radius: radius,
      paint: Paint()..color = backgroundColor,
    );
    await add(bg);

    // Sprite icon in the center
    final iconSize = radius * 1.2;
    final icon = SpriteComponent(
      sprite: sprite,
      size: Vector2.all(iconSize),
      position: Vector2.all(radius),
      anchor: Anchor.center,
    );
    await add(icon);
  }
}

class TextButtonComponent extends PositionComponent {
  final String text;
  final Color backgroundColor;

  TextButtonComponent({
    required this.text,
    double width = 80,
    double height = 40,
    required this.backgroundColor,
  }) : super(size: Vector2(width, height));

  @override
  Future<void> onLoad() async {
    final bg = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );
    await add(bg);

    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF00FFCC).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    await add(border);

    final textComp = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00FFCC),
          fontSize: 8,
          fontWeight: FontWeight.bold,
          fontFamily: 'Press Start 2P',
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    await add(textComp);
  }
}
