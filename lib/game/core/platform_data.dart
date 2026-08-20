import 'package:flame/extensions.dart';

class PlatformData {
  final Vector2 position;
  final Vector2 size;
  final bool isBreakable;

  const PlatformData({
    required this.position,
    required this.size,
    this.isBreakable = false,
  });
}
