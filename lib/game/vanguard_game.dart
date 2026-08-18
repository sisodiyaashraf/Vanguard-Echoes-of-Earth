import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:vanguard_echoes_of_earth/game/components/dragon_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/ground.dart';

class VanguardGame extends FlameGame with HasKeyboardHandlerComponents {
  late final Ground ground;
  late final DragonHero hero;

  @override
  Color backgroundColor() => const Color(0xFF111218);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create the test platform in world space
    ground = Ground(
      position: Vector2(-1000, 300),
      size: Vector2(2000, 50),
    );
    await world.add(ground);

    // Create the hero (spawned above the ground)
    hero = DragonHero(
      position: Vector2(100, 100),
    );
    await world.add(hero);

    // Configure the camera to follow the hero with a slight zoom for better pixel art scaling
    camera.viewfinder.zoom = 1.5;
    camera.follow(hero);
  }
}
