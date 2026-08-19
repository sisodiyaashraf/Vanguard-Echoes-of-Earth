import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:vanguard_echoes_of_earth/game/components/base_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/dragon_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/t_rex_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/curator_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/shark_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/kitsune_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/active_indicator.dart';
import 'package:vanguard_echoes_of_earth/game/components/ground.dart';

class VanguardGame extends FlameGame with HasKeyboardHandlerComponents {
  late final Ground ground;
  
  // Hero Switching State
  late final List<BaseHero> heroes;
  int activeHeroIndex = 0;
  BaseHero get activeHero => heroes[activeHeroIndex];

  // Visual tell above active hero
  late final ActiveIndicator activeIndicator;

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

    // Initialize all 5 heroes in fixed order, slightly spread out horizontally
    heroes = [
      DragonHero(position: Vector2(100, 100)),
      TRexHero(position: Vector2(200, 100)),
      CuratorHero(position: Vector2(300, 100)),
      SharkHero(position: Vector2(400, 100)),
      KitsuneHero(position: Vector2(500, 100)),
    ];

    for (var h in heroes) {
      await world.add(h);
    }

    // Set Dragon as active by default
    heroes[0].isActive = true;

    // Attach visual indicator above the active hero
    activeIndicator = ActiveIndicator();
    activeIndicator.position = Vector2(0, -heroes[0].size.y / 2 - 10);
    await heroes[0].add(activeIndicator);

    // Configure the camera to follow the hero with a slight zoom for better pixel art scaling
    camera.viewfinder.zoom = 1.5;
    camera.follow(heroes[0]);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      // Toggle / switch between heroes using Tab or Q
      if (keysPressed.contains(LogicalKeyboardKey.tab) ||
          keysPressed.contains(LogicalKeyboardKey.keyQ)) {
        cycleHero();
        return KeyEventResult.handled;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void cycleHero() {
    // 1. Deactivate old active hero and remove indicator
    final oldHero = activeHero;
    oldHero.isActive = false;
    activeIndicator.removeFromParent();

    // 2. Increment and wrap index
    activeHeroIndex = (activeHeroIndex + 1) % heroes.length;

    // 3. Activate new hero and attach indicator
    final newHero = activeHero;
    newHero.isActive = true;
    activeIndicator.position = Vector2(0, -newHero.size.y / 2 - 10);
    newHero.add(activeIndicator);

    // 4. Smoothly shift camera to new active hero
    camera.follow(newHero);
  }
}


