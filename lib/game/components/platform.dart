import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/components/melee_strike.dart';
import 'package:vanguard_echoes_of_earth/game/components/plasma_shockwave.dart';
import 'package:vanguard_echoes_of_earth/game/components/seismic_slam.dart';
import 'package:vanguard_echoes_of_earth/game/components/temporal_wave.dart';
import 'package:vanguard_echoes_of_earth/game/components/water_blade_barrage.dart';

class Platform extends PositionComponent with HasGameReference<VanguardGame>, CollisionCallbacks {
  final bool isBreakable;

  Platform({
    super.position,
    super.size,
    this.isBreakable = false,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (isBreakable) {
      add(RectangleHitbox());
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (isBreakable) {
      if (other is MeleeStrike ||
          other is PlasmaShockwave ||
          other is SeismicSlam ||
          other is TemporalWave ||
          other is WaterBlade) {
        FlameAudio.play('enemy_death.wav', volume: SaveManager.getSfxVolume());
        removeFromParent();
      }
    }
  }

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
