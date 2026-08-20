import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vanguard_echoes_of_earth/game/components/base_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/dragon_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/t_rex_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/curator_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/shark_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/kitsune_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/active_indicator.dart';
import 'package:vanguard_echoes_of_earth/game/components/ground.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/story/hero_backstory.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_config.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_registry.dart';
import 'package:vanguard_echoes_of_earth/game/components/parallax_background.dart';
import 'package:vanguard_echoes_of_earth/game/components/hud_buttons.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_enemy.dart';
import 'package:vanguard_echoes_of_earth/game/components/melee_strike.dart';
import 'package:vanguard_echoes_of_earth/game/components/plasma_shockwave.dart';
import 'package:vanguard_echoes_of_earth/game/components/seismic_slam.dart';
import 'package:vanguard_echoes_of_earth/game/components/temporal_wave.dart';
import 'package:vanguard_echoes_of_earth/game/components/water_blade_barrage.dart';

class VanguardGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final Ground ground;
  JoystickComponent? joystick;
  bool _levelCompleted = false;
  
  // Hero Switching State
  late final List<BaseHero> heroes;
  int activeHeroIndex = 0;
  BaseHero get activeHero => heroes[activeHeroIndex];

  // Story / Dialogue State
  final ValueNotifier<StoryEntry?> currentDialogueNotifier = ValueNotifier<StoryEntry?>(null);
  final List<StoryEntry> dialogueQueue = [];
  bool get isInputGated => currentDialogueNotifier.value != null;

  // Level State
  late final ParallaxBackground parallaxBackground;
  LevelConfig? currentLevelConfig;

  late final Map<String, HeroBackstory> backstories;

  final List<StoryEntry> introSequence = const [
    StoryEntry(
      speakerName: 'Narrator',
      text: 'Deep beneath the planet\'s surface, the Hollow has awakened. A creeping corruption that threatens to consume the Earth.',
    ),
    StoryEntry(
      speakerName: 'Narrator',
      text: 'From the ashes of the old world, five heroes arise: Dragon, T-Rex, Curator, Shark, and Kitsune.',
    ),
    StoryEntry(
      speakerName: 'Dragon',
      portraitAssetPath: 'assets/images/characters/Hero 1 Dragon — Kinetic Scales.png',
      text: 'We are the Vanguard. Let\'s push back this darkness together.',
    ),
  ];

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

    // Set up camera with a fixed resolution viewport and viewfinder visible game size
    camera = CameraComponent.withFixedResolution(width: 1280, height: 720);
    camera.viewfinder.visibleGameSize = Vector2(1000, 600);

    // Initialize background parallax first to render behind everything
    parallaxBackground = ParallaxBackground();
    await world.add(parallaxBackground);

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
      position: Vector2(0, 450),
      size: Vector2(2000, 150),
    );
    await world.add(ground);

    // Initialize all 5 heroes in fixed order, slightly spread out horizontally
    heroes = [
      DragonHero(position: Vector2(100, 386)),
      TRexHero(position: Vector2(200, 386)),
      CuratorHero(position: Vector2(300, 386)),
      SharkHero(position: Vector2(400, 386)),
      KitsuneHero(position: Vector2(500, 386)),
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

    // Configure the camera to follow the hero
    camera.follow(heroes[0]);

    // Create virtual joystick and action buttons for touch devices on the camera viewport
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 25,
        paint: Paint()..color = const Color(0xFF00FFCC).withValues(alpha: 0.5),
      ),
      background: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.black.withValues(alpha: 0.3),
      ),
      margin: const EdgeInsets.only(left: 60, bottom: 60),
    );
    await camera.viewport.add(joystick!);

    final jumpButton = HudButtonComponent(
      button: RoundIconButton(
        sprite: runSprite,
        radius: 30,
        backgroundColor: Colors.black.withValues(alpha: 0.5),
      ),
      buttonDown: RoundIconButton(
        sprite: runSprite,
        radius: 27,
        backgroundColor: const Color(0xFF00FFCC).withValues(alpha: 0.4),
      ),
      margin: const EdgeInsets.only(right: 130, bottom: 180),
      onPressed: () {
        activeHero.inputState.jumpPressed = true;
      },
    );
    await camera.viewport.add(jumpButton);

    final attackButton = HudButtonComponent(
      button: RoundIconButton(
        sprite: meleeSprite,
        radius: 35,
        backgroundColor: Colors.black.withValues(alpha: 0.5),
      ),
      buttonDown: RoundIconButton(
        sprite: meleeSprite,
        radius: 32,
        backgroundColor: const Color(0xFF00FFCC).withValues(alpha: 0.4),
      ),
      margin: const EdgeInsets.only(right: 40, bottom: 120),
      onPressed: () {
        activeHero.inputState.attackPressed = true;
      },
    );
    await camera.viewport.add(attackButton);

    final powerButton = HudButtonComponent(
      button: RoundIconButton(
        sprite: plasmaSprite,
        radius: 30,
        backgroundColor: Colors.black.withValues(alpha: 0.5),
      ),
      buttonDown: RoundIconButton(
        sprite: plasmaSprite,
        radius: 27,
        backgroundColor: const Color(0xFF00FFCC).withValues(alpha: 0.4),
      ),
      margin: const EdgeInsets.only(right: 130, bottom: 60),
      onPressed: () {
        activeHero.inputState.powerPressed = true;
      },
    );
    await camera.viewport.add(powerButton);

    final swapButton = HudButtonComponent(
      button: TextButtonComponent(
        text: 'SWAP',
        backgroundColor: Colors.black.withValues(alpha: 0.6),
      ),
      buttonDown: TextButtonComponent(
        text: 'SWAP',
        backgroundColor: const Color(0xFF00FFCC).withValues(alpha: 0.3),
      ),
      margin: const EdgeInsets.only(right: 20, top: 20),
      onPressed: () {
        if (currentLevelConfig == null || currentLevelConfig!.heroId == 'team') {
          cycleHero();
        } else {
          showDialogue([
            StoryEntry(
              speakerName: 'System',
              text: 'Hero switching is locked for Solo Mission: ${currentLevelConfig!.displayName}.',
            )
          ]);
        }
      },
    );
    await camera.viewport.add(swapButton);

    // Initialize Backstories
    backstories = {
      'Dragon': HeroBackstory(
        heroName: 'Dragon',
        lockedEntries: const [
          StoryEntry(
            speakerName: 'Dragon',
            portraitAssetPath: 'assets/images/characters/Hero 1 Dragon — Kinetic Scales.png',
            text: 'The rescue mission... The fire was too hot, the smoke too thick. I couldn\'t save my sibling.',
          ),
          StoryEntry(
            speakerName: 'Dragon',
            portraitAssetPath: 'assets/images/characters/Hero 1 Dragon — Kinetic Scales.png',
            text: 'I swore I\'d never take flight again. The guilt was a weight I couldn\'t carry.',
          ),
          StoryEntry(
            speakerName: 'Dragon',
            portraitAssetPath: 'assets/images/characters/Hero 1 Dragon — Kinetic Scales.png',
            text: 'But now the Hollow threatens everything. I must soar once more, not for glory, but to save them.',
          ),
        ],
      ),
      'T-Rex': HeroBackstory(
        heroName: 'T-Rex',
        lockedEntries: const [
          StoryEntry(
            speakerName: 'T-Rex',
            portraitAssetPath: 'assets/images/characters/Hero 2 T-Rex (Seismic Hammer).png',
            text: 'I was too ambitious. I ordered the dig to continue, ignoring the geological warnings.',
          ),
          StoryEntry(
            speakerName: 'T-Rex',
            portraitAssetPath: 'assets/images/characters/Hero 2 T-Rex (Seismic Hammer).png',
            text: 'The cave-in... My team was trapped. I escaped, but my reputation and soul were buried there.',
          ),
          StoryEntry(
            speakerName: 'T-Rex',
            portraitAssetPath: 'assets/images/characters/Hero 2 T-Rex (Seismic Hammer).png',
            text: 'Now, I will stand as an unbreakable shield. No one else gets left behind on my watch.',
          ),
        ],
      ),
      'Curator': HeroBackstory(
        heroName: 'Curator',
        lockedEntries: const [
          StoryEntry(
            speakerName: 'Curator',
            portraitAssetPath: 'assets/images/characters/Curator (Temporal Nanotech).png',
            text: 'To free the hostage from the temple, I triggered the relic\'s ancient curse.',
          ),
          StoryEntry(
            speakerName: 'Curator',
            portraitAssetPath: 'assets/images/characters/Curator (Temporal Nanotech).png',
            text: 'The price is my own mind. Every day, the faces of my past fade a little more.',
          ),
          StoryEntry(
            speakerName: 'Curator',
            portraitAssetPath: 'assets/images/characters/Curator (Temporal Nanotech).png',
            text: 'I must fight to hold onto who I am, to keep my humanity before the memories are completely gone.',
          ),
        ],
      ),
      'Shark': HeroBackstory(
        heroName: 'Shark',
        lockedEntries: const [
          StoryEntry(
            speakerName: 'Shark',
            portraitAssetPath: 'assets/images/characters/Shark (Hydrokinetic Agility).png',
            text: 'The submarine hull cracked. The dark, cold abyss rushed in. I was the sole survivor.',
          ),
          StoryEntry(
            speakerName: 'Shark',
            portraitAssetPath: 'assets/images/characters/Shark (Hydrokinetic Agility).png',
            text: 'Ever since, the depth of the ocean terrifies me. The thalassophobia is paralyzing.',
          ),
          StoryEntry(
            speakerName: 'Shark',
            portraitAssetPath: 'assets/images/characters/Shark (Hydrokinetic Agility).png',
            text: 'But my team needs a protector. I will conquer this fear and conquer the tides.',
          ),
        ],
      ),
      'Kitsune': HeroBackstory(
        heroName: 'Kitsune',
        lockedEntries: const [
          StoryEntry(
            speakerName: 'Kitsune',
            portraitAssetPath: 'assets/images/characters/Kitsune (Holographic).png',
            text: 'An orphan on the neon streets, nobody cared. I survived by stealing and deceiving.',
          ),
          StoryEntry(
            speakerName: 'Kitsune',
            portraitAssetPath: 'assets/images/characters/Kitsune (Holographic).png',
            text: 'Illusions became my armor. If they only see a mask, they can never hurt the real me.',
          ),
          StoryEntry(
            speakerName: 'Kitsune',
            portraitAssetPath: 'assets/images/characters/Kitsune (Holographic).png',
            text: 'These heroes... they look at me with trust. Maybe it\'s time to drop the illusions.',
          ),
        ],
      ),
    };

    // Load first level by default
    await loadLevel(LevelRegistry.levels[0]);

    // Play intro sequence
    showDialogue(introSequence);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      // 1. Handle Escape key to pause/unpause the game
      if (keysPressed.contains(LogicalKeyboardKey.escape)) {
        if (paused) {
          paused = false;
          overlays.remove('pause');
        } else {
          paused = true;
          overlays.add('pause');
        }
        return KeyEventResult.handled;
      }

      // 2. Handle Restart Key (KeyR)
      if (keysPressed.contains(LogicalKeyboardKey.keyR)) {
        if (currentLevelConfig != null) {
          loadLevel(currentLevelConfig!);
        }
        return KeyEventResult.handled;
      }

      // 3. If dialogue is active, handle Enter key to advance dialogue and gate everything else
      if (isInputGated) {
        if (keysPressed.contains(LogicalKeyboardKey.enter)) {
          advanceDialogue();
        }
        return KeyEventResult.handled;
      }

      // 4. Toggle / switch between heroes using Tab or Q
      if (keysPressed.contains(LogicalKeyboardKey.tab) ||
          keysPressed.contains(LogicalKeyboardKey.keyQ)) {
        if (currentLevelConfig == null || currentLevelConfig!.heroId == 'team') {
          cycleHero();
        } else {
          showDialogue([
            StoryEntry(
              speakerName: 'System',
              text: 'Hero switching is locked for Solo Mission: ${currentLevelConfig!.displayName}.',
            )
          ]);
        }
        return KeyEventResult.handled;
      }
    }

    if (isInputGated) {
      return KeyEventResult.handled;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void showDialogue(List<StoryEntry> entries) {
    dialogueQueue.addAll(entries);
    if (currentDialogueNotifier.value == null && dialogueQueue.isNotEmpty) {
      currentDialogueNotifier.value = dialogueQueue.removeAt(0);
      overlays.add('dialogue');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (joystick != null) {
      if (joystick!.relativeDelta.length > 0) {
        activeHero.inputState.joystickMoveX = joystick!.relativeDelta.x;
      } else {
        activeHero.inputState.joystickMoveX = 0.0;
      }
    }

    if (currentLevelConfig != null && !_levelCompleted) {
      final enemies = world.children.whereType<HollowEnemy>();
      if (currentLevelConfig!.enemySpawnPoints != null && currentLevelConfig!.enemySpawnPoints!.isNotEmpty) {
        final activeEnemiesCount = enemies.where((e) => e.health > 0).length;
        if (activeEnemiesCount == 0) {
          _levelCompleted = true;
          _completeLevel();
        }
      } else {
        final endTriggerX = currentLevelConfig!.levelSize.x - 150;
        if (activeHero.position.x >= endTriggerX) {
          _levelCompleted = true;
          _completeLevel();
        }
      }
    }
  }

  void _completeLevel() {
    final isTrial = currentLevelConfig?.id.endsWith('_5') ?? false;

    List<StoryEntry> entries = [];
    entries.add(StoryEntry(
      speakerName: 'System',
      text: 'Level Complete! Mission ${currentLevelConfig?.displayName} successful.',
    ));

    if (isTrial) {
      final hero = activeHero;
      final backstory = backstories[hero.heroName];
      if (backstory != null) {
        final entry = backstory.unlockNext();
        if (entry != null) {
          entries.add(StoryEntry(
            speakerName: 'System',
            text: 'TRIAL CONCLUDED: Next backstory entry unlocked for ${hero.heroName}!',
          ));
          entries.add(entry);
        } else {
          entries.add(StoryEntry(
            speakerName: 'System',
            text: 'TRIAL CONCLUDED: All backstory entries for ${hero.heroName} are already unlocked.',
          ));
        }
      }
    }

    showDialogue(entries);
  }

  void advanceDialogue() {
    if (dialogueQueue.isNotEmpty) {
      currentDialogueNotifier.value = dialogueQueue.removeAt(0);
    } else {
      currentDialogueNotifier.value = null;
      overlays.remove('dialogue');

      if (_levelCompleted) {
        _levelCompleted = false;
        overlays.add('level_selection');
      }
    }
  }

  void unlockCurrentHeroBackstory() {
    final hero = activeHero;
    final backstory = backstories[hero.heroName];
    if (backstory != null) {
      final entry = backstory.unlockNext();
      if (entry != null) {
        showDialogue([entry]);
      } else {
        showDialogue([
          StoryEntry(
            speakerName: 'System',
            text: 'All backstory entries for ${hero.heroName} have already been unlocked.',
          )
        ]);
      }
    }
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

  Future<void> loadLevel(LevelConfig config) async {
    currentLevelConfig = config;
    _levelCompleted = false;
    await parallaxBackground.changeLevelBackground(config.backgroundAssetPath);

    // Resize ground dynamically based on the current level config
    ground.position = Vector2(0, config.levelSize.y - 150);
    ground.size = Vector2(config.levelSize.x, 150);

    // Remove all existing enemies and projectiles from the world
    final existingEnemies = world.children.whereType<HollowEnemy>();
    for (var enemy in existingEnemies.toList()) {
      enemy.removeFromParent();
    }

    final existingProjectiles = world.children.where((c) =>
        c is MeleeStrike ||
        c is PlasmaShockwave ||
        c is SeismicSlam ||
        c is TemporalWave ||
        c is WaterBlade
    );
    for (var proj in existingProjectiles.toList()) {
      proj.removeFromParent();
    }

    // Enforce hero requirements (force active hero according to level assignment)
    if (config.heroId != 'team') {
      final reqHeroIndex = heroes.indexWhere(
        (h) => h.heroName.toLowerCase() == config.heroId.toLowerCase(),
      );
      if (reqHeroIndex != -1 && reqHeroIndex != activeHeroIndex) {
        final oldHero = activeHero;
        oldHero.isActive = false;
        activeIndicator.removeFromParent();

        activeHeroIndex = reqHeroIndex;

        final newHero = activeHero;
        newHero.isActive = true;
        activeIndicator.position = Vector2(0, -newHero.size.y / 2 - 10);
        await newHero.add(activeIndicator);

        camera.follow(newHero);
      }
    }

    // Spread all heroes out on the ground
    for (int i = 0; i < heroes.length; i++) {
      heroes[i].position = Vector2(100.0 + (i * 100.0), ground.position.y - heroes[i].size.y / 2);
      heroes[i].velocity.setZero();
    }

    // Reset active hero position to start of level
    activeHero.position = Vector2(100, ground.position.y - activeHero.size.y / 2);
    activeHero.velocity.setZero();

    // Spawn Hollow enemies on top of the platform based on config points
    if (config.enemySpawnPoints != null) {
      for (int i = 0; i < config.enemySpawnPoints!.length; i++) {
        final pt = config.enemySpawnPoints![i];
        final enemy = HollowEnemy(
          enemyType: i % 4,
          position: Vector2(pt.x, ground.position.y - 64.0),
        );
        await world.add(enemy);
      }
    }

    // Play level's introSequence if present
    if (config.introSequence != null && config.introSequence!.isNotEmpty) {
      showDialogue(config.introSequence!);
    } else {
      showDialogue([
        StoryEntry(
          speakerName: 'System',
          text: 'Entering Level: ${config.displayName}',
        ),
      ]);
    }
  }
}


