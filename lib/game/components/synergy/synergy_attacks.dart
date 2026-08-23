import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_enemy.dart';
import 'package:vanguard_echoes_of_earth/game/components/platform.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';

// Announcement text that displays huge neon orange synergy titles
class SynergyAnnouncementText extends TextComponent with HasGameReference<VanguardGame> {
  double _elapsed = 0.0;

  SynergyAnnouncementText({required String title, required Vector2 position})
      : super(
          text: title,
          position: position,
          anchor: Anchor.center,
          priority: 5,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Color(0xFFFF5722),
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              shadows: [
                Shadow(color: Colors.white, blurRadius: 10.0),
              ],
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= 30 * dt;
    _elapsed += dt;
    if (_elapsed >= 2.0) {
      removeFromParent();
    } else {
      final double progress = (_elapsed / 2.0).clamp(0.0, 1.0);
      final alpha = (255 * (1.0 - progress)).toInt();
      textRenderer = TextPaint(
        style: TextStyle(
          color: const Color(0xFFFF5722).withAlpha(alpha),
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          shadows: [
            Shadow(color: Colors.white.withAlpha(alpha), blurRadius: 10.0),
          ],
        ),
      );
    }
  }
}

// 1. Steam Burst (Dragon + Shark)
class SteamBurst extends PositionComponent with HasGameReference<VanguardGame> {
  final double duration = 2.0;
  final int damage = 35;
  double _elapsed = 0.0;

  SteamBurst({required Vector2 position})
      : super(
          position: position,
          size: Vector2(300, 300),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
    game.obscuredTimeRemaining = 4.0; // obscure enemy vision for 4 seconds
    FlameAudio.play('landing.wav', volume: SaveManager.getSfxVolume());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = (150 * (1.0 - progress)).toInt();

    final paint = Paint()
      ..color = Colors.white.withAlpha(alpha)
      ..style = PaintingStyle.fill;

    // Draw expanding steam cloud spheres
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), (size.x / 2) * progress, paint);
    canvas.drawCircle(Offset(size.x / 2 - 40, size.y / 2 + 20), (size.x / 3) * progress, paint);
    canvas.drawCircle(Offset(size.x / 2 + 40, size.y / 2 - 20), (size.x / 3) * progress, paint);
  }
}

// 2. Aged Quake (T-Rex + Curator)
class AgedQuake extends PositionComponent with HasGameReference<VanguardGame> {
  final double duration = 1.0;
  final int damage = 50;
  double _elapsed = 0.0;

  AgedQuake({required Vector2 position})
      : super(
          position: position,
          size: Vector2(500, 100),
          anchor: Anchor.bottomCenter,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    FlameAudio.play('power.wav', volume: SaveManager.getSfxVolume());

    // Break any platforms in immediate horizontal range
    final platforms = game.world.children.whereType<Platform>().toList();
    for (var plat in platforms) {
      if (plat.isBreakable && (plat.position.x - position.x).abs() < 400) {
        plat.removeFromParent();
        FlameAudio.play('enemy_death.wav', volume: SaveManager.getSfxVolume());
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = (180 * (1.0 - progress)).toInt();

    final paint = Paint()
      ..color = const Color(0xFF8B4513).withAlpha(alpha) // Earth Brown
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final crackPath = Path()
      ..moveTo(0, size.y)
      ..lineTo(size.x * 0.25 * progress, size.y - 20)
      ..lineTo(size.x * 0.5 * progress, size.y)
      ..lineTo(size.x * 0.75 * progress, size.y - 30)
      ..lineTo(size.x * progress, size.y);

    canvas.drawPath(crackPath, paint);
  }
}

// 3. Mirage Clone (Kitsune + Shark)
class MirageClone extends PositionComponent with HasGameReference<VanguardGame> {
  final double duration = 3.5;
  final int damage = 25;
  double _elapsed = 0.0;
  double _bladeTimer = 0.0;
  final double direction; // +1 or -1

  MirageClone({required Vector2 position, required this.direction})
      : super(
          position: position,
          size: Vector2(128, 128),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: 40, position: Vector2(24, 24)));
    scale.x = direction;
    FlameAudio.play('jump.wav', volume: SaveManager.getSfxVolume() * 0.7);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    // Periodically pulse water blade offensive damage triggers
    _bladeTimer += dt;
    if (_bladeTimer >= 0.6) {
      _bladeTimer = 0.0;
      FlameAudio.play('landing.wav', volume: SaveManager.getSfxVolume() * 0.4);
    }

    // Float slowly forward
    position.x += direction * 60 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = (120 * (1.0 - progress)).toInt();

    final paint = Paint()
      ..color = const Color(0xFF00FFCC).withAlpha(alpha) // Neon Cyan
      ..style = PaintingStyle.fill;

    // Draw defensive holographic decoy body
    canvas.drawOval(size.toRect(), paint);

    // Draw spinning water blades orbits
    final orbitPaint = Paint()
      ..color = const Color(0xFF00BFFF).withAlpha(alpha)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final angle = _elapsed * 6;
    final r = 60.0;
    canvas.drawCircle(Offset(size.x / 2 + cos(angle) * r, size.y / 2 + sin(angle) * r), 12, orbitPaint);
  }
}

// 4. Molten Impact (Dragon + T-Rex)
class MoltenImpact extends PositionComponent with HasGameReference<VanguardGame> {
  final double duration = 1.2;
  final int damage = 60;
  double _elapsed = 0.0;

  MoltenImpact({required Vector2 position})
      : super(
          position: position,
          size: Vector2(400, 400),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
    FlameAudio.play('power.wav', volume: SaveManager.getSfxVolume());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = (200 * (1.0 - progress)).toInt();

    final fillPaint = Paint()
      ..color = const Color(0xFFFF4500).withAlpha(alpha) // Orange-Red
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFFFD700).withAlpha(alpha) // Gold Yellow
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final radius = (size.x / 2) * progress;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, fillPaint);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, borderPaint);
  }
}

// 5. Time Phantom (Curator + Kitsune)
class TimePhantom extends PositionComponent with HasGameReference<VanguardGame> {
  final double duration = 3.0;
  final int damage = 30;
  double _elapsed = 0.0;

  TimePhantom({required Vector2 position})
      : super(
          position: position,
          size: Vector2(250, 250),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
    FlameAudio.play('power.wav', volume: SaveManager.getSfxVolume() * 0.8);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = (160 * (1.0 - progress)).toInt();

    final paint = Paint()
      ..color = const Color(0xFFBA55D3).withAlpha(alpha) // Medium Orchid Purple
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.x / 2, size.y / 2);
    final r = (size.x / 2) * (0.3 + 0.7 * sin(_elapsed * 5).abs());

    // Draw clock face circle
    canvas.drawCircle(center, r, paint);

    // Draw clock hand clock lines
    final handPaint = Paint()
      ..color = const Color(0xFFBA55D3).withAlpha(alpha)
      ..strokeWidth = 3.0;
    canvas.drawLine(center, Offset(center.dx + cos(_elapsed * 4) * r, center.dy + sin(_elapsed * 4) * r), handPaint);
  }
}
