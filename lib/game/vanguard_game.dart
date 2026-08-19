import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:vanguard_echoes_of_earth/game/components/dragon_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/ground.dart';

class VanguardGame extends FlameGame with HasKeyboardHandlerComponents {
  late final Ground ground;
  late final DragonHero hero;

  // Cache of UI Sprites from "characters/UI elements (icons, not animated).png"
  late final Sprite heartSprite;
  late final Sprite energySprite;
  late final Sprite coinSprite;
  late final Sprite meleeSprite;
  late final Sprite runSprite;
  late final Sprite plasmaSprite;

  @override
  Color backgroundColor() => const Color(0xFF111218);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the UI sprite sheet
    final uiSheet = await images.load('characters/UI elements (icons, not animated).png');
    heartSprite = Sprite(uiSheet, srcPosition: Vector2(63, 390), srcSize: Vector2(218, 203));
    energySprite = Sprite(uiSheet, srcPosition: Vector2(313, 390), srcSize: Vector2(155, 203));
    coinSprite = Sprite(uiSheet, srcPosition: Vector2(507, 379), srcSize: Vector2(180, 214));
    meleeSprite = Sprite(uiSheet, srcPosition: Vector2(720, 372), srcSize: Vector2(228, 232));
    runSprite = Sprite(uiSheet, srcPosition: Vector2(970, 372), srcSize: Vector2(228, 231));
    plasmaSprite = Sprite(uiSheet, srcPosition: Vector2(1220, 372), srcSize: Vector2(227, 231));

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

