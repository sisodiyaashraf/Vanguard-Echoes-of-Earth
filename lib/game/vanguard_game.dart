import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:vanguard_echoes_of_earth/game/components/base_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/dragon_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/t_rex_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/curator_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/shark_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/kitsune_hero.dart';
import 'package:vanguard_echoes_of_earth/game/components/active_indicator.dart';
import 'package:vanguard_echoes_of_earth/game/components/platform.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/story/hero_backstory.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_config.dart';
import 'package:vanguard_echoes_of_earth/game/components/parallax_background.dart';
import 'package:vanguard_echoes_of_earth/game/components/hud_buttons.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_enemy.dart';
import 'package:vanguard_echoes_of_earth/game/components/melee_strike.dart';
import 'package:vanguard_echoes_of_earth/game/components/plasma_shockwave.dart';
import 'package:vanguard_echoes_of_earth/game/components/seismic_slam.dart';
import 'package:vanguard_echoes_of_earth/game/components/temporal_wave.dart';
import 'package:vanguard_echoes_of_earth/game/components/water_blade_barrage.dart';
import 'package:vanguard_echoes_of_earth/game/core/game_state.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_boss.dart';
import 'package:vanguard_echoes_of_earth/game/core/tutorial_controller.dart';
import 'package:vanguard_echoes_of_earth/game/components/element_particle.dart';
import 'package:vanguard_echoes_of_earth/game/components/dust_particle.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';
import 'package:vanguard_echoes_of_earth/game/progression/achievement.dart';
import 'package:vanguard_echoes_of_earth/game/progression/daily_challenge.dart';
import 'package:vanguard_echoes_of_earth/game/progression/notification_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:vanguard_echoes_of_earth/game/modes/boss_rush_config.dart';
import 'package:vanguard_echoes_of_earth/game/modes/survival_config.dart';
import 'package:vanguard_echoes_of_earth/game/modes/boss_rush_manager.dart';
import 'package:vanguard_echoes_of_earth/game/modes/survival_manager.dart';
import 'package:vanguard_echoes_of_earth/game/components/synergy/synergy_attacks.dart';

class VanguardGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  final LevelConfig initialLevelConfig;
  JoystickComponent? joystick;
  GameState gameState = GameState.playing;
  bool hasPlayedTransformation = false;

  // Progression Tracking Flags
  bool hasUsedPowerThisLevel = false;
  bool hasTakenDamageThisLevel = false;

  // Hero Switching State
  late List<BaseHero> heroes;
  int activeHeroIndex = 0;
  BaseHero get activeHero => heroes[activeHeroIndex];

  VanguardGame({required this.initialLevelConfig});

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

    // Configure the default camera's viewfinder visible game size
    camera.viewfinder.visibleGameSize = Vector2(640, 360);

    // Initialize background parallax first to render behind everything
    parallaxBackground = ParallaxBackground();
    await add(parallaxBackground);

    // Load the UI sprite sheet
    final uiSheet = await images.load('characters/UI elements (icons, not animated).png');
    heartSprite = Sprite(uiSheet, srcPosition: Vector2(63, 390), srcSize: Vector2(218, 203));
    energySprite = Sprite(uiSheet, srcPosition: Vector2(313, 390), srcSize: Vector2(155, 203));
    coinSprite = Sprite(uiSheet, srcPosition: Vector2(507, 379), srcSize: Vector2(180, 214));
    meleeSprite = Sprite(uiSheet, srcPosition: Vector2(720, 372), srcSize: Vector2(228, 232));
    runSprite = Sprite(uiSheet, srcPosition: Vector2(970, 372), srcSize: Vector2(228, 231));
    plasmaSprite = Sprite(uiSheet, srcPosition: Vector2(1220, 372), srcSize: Vector2(227, 231));

    // Initialize audio bgm
    await FlameAudio.bgm.initialize();

    // Initialize SharedPreferences SaveManager
    await SaveManager.init();

    // Preload commonly-used assets to prevent runtime loading stutters
    final imagesToPreload = [
      'characters/Enemy sprites (The Hollow).png',
      'characters/VFX (effects, transparent).png',
      'characters/Hero 1 Dragon — Kinetic Scales.png',
      'characters/Dragon - run.png',
      'characters/Dragon - jump and attack.png',
      'characters/dragon kinetic (superpower).png',
      'characters/dragon kinetic (transformation).png',
      'characters/Hero 2 T-Rex (Seismic Hammer).png',
      'characters/T-Rex - run.png',
      'characters/T-Rex - jump and attack.png',
      'characters/t-rex seismic (superpower).png',
      'characters/t-rex seismic (transformation).png',
      'characters/Curator (Temporal Nanotech).png',
      'characters/Curator - run.png',
      'characters/Curator - jump and attack.png',
      'characters/curator temporal (superpower).png',
      'characters/curator temporal (transformation).png',
      'characters/Shark (Hydrokinetic Agility).png',
      'characters/Shark - run.png',
      'characters/Shark - jump and attack.png',
      'characters/shark hydrokinetic (superpower).png',
      'characters/shark hydrokinetic (transformation).png',
      'characters/Kitsune (Holographic).png',
      'characters/Kitsune - run.png',
      'characters/Kitsune - jump and attack.png',
      'characters/kitsune holographic (superpower).png',
      'characters/kitsune holographic (transformation).png',
      'backgrounds/fire_sky.png',
      'backgrounds/earth_underground.png',
      'backgrounds/ancient_museum.png',
      'backgrounds/water_ocean.png',
      'backgrounds/urban_tech.png',
    ];
    await images.loadAll(imagesToPreload);

    // Create the initial platform in world space
    final initialPlatform = Platform(
      position: Vector2(0, 450),
      size: Vector2(2000, 150),
    );
    await world.add(initialPlatform);

    activeIndicator = ActiveIndicator();

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

    // Load persisted backstory unlocks for all heroes
    backstories.forEach((heroName, backstory) {
      final unlockedCount = SaveManager.getUnlockedBackstoryCount(heroName);
      for (int i = 0; i < unlockedCount; i++) {
        backstory.unlockNext();
      }
    });

    // Load selected level
    await loadLevel(initialLevelConfig);

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
    TutorialController.instance.update(this, dt);

    if (joystick != null) {
      if (isInputGated || paused) {
        joystick!.relativeDelta.setZero();
        activeHero.inputState.joystickMoveX = 0.0;
      } else if (joystick!.relativeDelta.length > 0) {
        activeHero.inputState.joystickMoveX = joystick!.relativeDelta.x;
      } else {
        activeHero.inputState.joystickMoveX = 0.0;
      }
    }

    if (currentLevelConfig != null && gameState == GameState.playing) {
      final enemies = world.children.whereType<HollowEnemy>();
      if (currentLevelConfig!.enemySpawnPoints != null && currentLevelConfig!.enemySpawnPoints!.isNotEmpty) {
        final activeEnemiesCount = enemies.where((e) => e.health > 0).length;
        if (activeEnemiesCount == 0) {
          _completeLevel();
        }
      } else {
        final endTriggerX = currentLevelConfig!.levelSize.x - 150;
        if (activeHero.position.x >= endTriggerX) {
          _completeLevel();
        }
      }
    }

    // Constrain camera viewfinder within level bounds
    if (currentLevelConfig != null) {
      final visibleSize = camera.viewfinder.visibleGameSize ?? Vector2(640, 360);
      final halfWidth = visibleSize.x / 2;
      final halfHeight = visibleSize.y / 2;
      
      double camX = camera.viewfinder.position.x;
      // Shift camera Y position up by 90 units to push the ground platform down to the bottom ~15% of screen
      double camY = camera.viewfinder.position.y - 90;
      
      camX = camX.clamp(halfWidth, currentLevelConfig!.levelSize.x - halfWidth);
      camY = camY.clamp(halfHeight, currentLevelConfig!.levelSize.y - halfHeight);
      
      camera.viewfinder.position = Vector2(camX, camY);
    }
  }

  void _completeLevel() {
    if (gameState == GameState.levelComplete) return;
    gameState = GameState.levelComplete;

    // Play win BGM/SFX and stop current music
    FlameAudio.bgm.stop();
    FlameAudio.play('win.wav', volume: SaveManager.getSfxVolume());

    // Save completed level
    if (currentLevelConfig != null) {
      SaveManager.saveCompletedLevel(currentLevelConfig!.id);
    }

    // Award Level Complete XP
    awardXp(CombatConstants.levelCompleteXpAward);

    // Check first level completed achievement
    unlockAchievement('first_level');

    // Check Dragon all levels completed achievement
    if (currentLevelConfig != null && currentLevelConfig!.id.startsWith('dragon_')) {
      bool allDragonCleared = true;
      for (int i = 1; i <= 5; i++) {
        if (!SaveManager.isLevelCompleted('dragon_$i') && currentLevelConfig!.id != 'dragon_$i') {
          allDragonCleared = false;
        }
      }
      if (allDragonCleared) {
        unlockAchievement('dragon_clear');
      }
    }

    // Check untouchable squad achievement
    if (currentLevelConfig?.heroId == 'team' && !hasTakenDamageThisLevel) {
      unlockAchievement('no_damage_team');
    }

    // Check daily challenge complete progress
    final challengeId = SaveManager.getCurrentChallengeId();
    if (challengeId == 'complete_2_levels') {
      final challenge = DailyChallenge.getChallengeById(challengeId);
      final progress = SaveManager.getDailyChallengeProgress() + 1;
      SaveManager.saveDailyChallengeProgress(progress);
      if (progress >= challenge.target && !SaveManager.isDailyChallengeCompleted()) {
        SaveManager.setDailyChallengeCompleted(true);
        awardDailyChallengeReward();
      }
    }

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

          // Save backstory unlock count
          final count = backstory.unlockedEntries.length;
          SaveManager.saveUnlockedBackstory(hero.heroName, count);

          // Check backstory seeker achievement
          if (count >= 3) {
            unlockAchievement('backstory_unlock');
          }
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

      if (gameState == GameState.levelComplete) {
        // Freeze gameplay and show complete menu
        paused = true;
        overlays.add('level_complete');
      } else if (gameState == GameState.playing && !hasPlayedTransformation) {
        hasPlayedTransformation = true;
        activeHero.triggerTransformation();
      }
    }
  }

  void triggerGameOver() {
    if (gameState == GameState.gameOver) return;
    gameState = GameState.gameOver;
    paused = true;
    FlameAudio.bgm.stop();
    FlameAudio.play('game_over.wav', volume: SaveManager.getSfxVolume());
    overlays.add('game_over');
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
    // 1. Deactivate old active hero and reset its inputs/velocity to stop moving
    final oldHero = activeHero;
    oldHero.inputState.reset();
    oldHero.velocity.setZero();
    activeIndicator.removeFromParent();

    // 2. Increment and wrap index
    activeHeroIndex = (activeHeroIndex + 1) % heroes.length;

    // 3. Activate new hero and attach indicator
    for (int i = 0; i < heroes.length; i++) {
      heroes[i].isActive = (i == activeHeroIndex);
    }

    final newHero = activeHero;
    activeIndicator.position = Vector2(0, -newHero.size.y / 2 - 10);
    newHero.add(activeIndicator);

    // Save last played hero id
    SaveManager.saveLastPlayedHeroId(newHero.heroName);

    // 4. Smoothly shift camera to new active hero
    camera.follow(newHero);
  }

  String _getBgmForHero(String heroId) {
    switch (heroId.toLowerCase()) {
      case 'dragon':
        return 'music_fire.wav';
      case 't-rex':
        return 'music_earth.wav';
      case 'shark':
        return 'music_ocean.wav';
      case 'curator':
        return 'music_ancient.wav';
      case 'kitsune':
        return 'music_tech.wav';
      case 'team':
      default:
        return 'music_team.wav';
    }
  }

  void playBgm(String file) {
    final vol = SaveManager.getBgmVolume();
    FlameAudio.bgm.play(file);
    try {
      FlameAudio.bgm.audioPlayer.setVolume(vol);
    } catch (_) {}
  }

  BaseHero _createHeroById(String id) {
    switch (id.toLowerCase()) {
      case 'dragon':
        return DragonHero();
      case 't-rex':
        return TRexHero();
      case 'curator':
        return CuratorHero();
      case 'shark':
        return SharkHero();
      case 'kitsune':
      default:
        return KitsuneHero();
    }
  }

  Future<void> loadLevel(LevelConfig config) async {
    currentLevelConfig = config;
    gameState = GameState.playing;
    paused = false;
    hasPlayedTransformation = false;
    hasUsedPowerThisLevel = false;
    hasTakenDamageThisLevel = false;
    overlays.remove('game_over');
    overlays.remove('level_complete');
    overlays.remove('pause');

    // Save last played hero id
    if (config.heroId == 'team') {
      SaveManager.saveLastPlayedHeroId('dragon');
    } else {
      SaveManager.saveLastPlayedHeroId(config.heroId);
    }

    await parallaxBackground.changeLevelBackground(config.backgroundAssetPath);

    // Remove all existing platforms, enemies, projectiles and heroes from the world
    final existingPlatforms = world.children.whereType<Platform>();
    for (var platform in existingPlatforms.toList()) {
      platform.removeFromParent();
    }

    final existingEnemies = world.children.whereType<HollowEnemy>();
    for (var enemy in existingEnemies.toList()) {
      enemy.removeFromParent();
    }

    final existingProjectiles = world.children.where((c) =>
        c is MeleeStrike ||
        c is PlasmaShockwave ||
        c is SeismicSlam ||
        c is TemporalWave ||
        c is WaterBlade ||
        c is BossFireLineSegment ||
        c is BossRockProjectile ||
        c is BossSeismicShockwave ||
        c is BossDecayPulse ||
        c is BossWaterBlade ||
        c is BossDecoy ||
        c is ElementParticle ||
        c is DustParticle
    );
    for (var proj in existingProjectiles.toList()) {
      proj.removeFromParent();
    }

    final existingHeroes = world.children.whereType<BaseHero>();
    for (var h in existingHeroes.toList()) {
      h.removeFromParent();
    }

    // Spawn platforms from config, or default flat platform
    if (config.platforms != null && config.platforms!.isNotEmpty) {
      for (var platData in config.platforms!) {
        final platform = Platform(
          position: platData.position,
          size: platData.size,
          isBreakable: platData.isBreakable,
        );
        await world.add(platform);
      }
    } else {
      final platform = Platform(
        position: Vector2(0, config.levelSize.y - 150),
        size: Vector2(config.levelSize.x, 150),
      );
      await world.add(platform);
    }

    // Spawn selected hero (or all 5 for team level)
    if (config.heroId == 'team') {
      heroes = [
        DragonHero(),
        TRexHero(),
        CuratorHero(),
        SharkHero(),
        KitsuneHero(),
      ];
      for (var h in heroes) {
        await world.add(h);
      }
      activeHeroIndex = 0;
      heroes[0].isActive = true;
      activeIndicator.removeFromParent();
      activeIndicator.position = Vector2(0, -heroes[0].size.y / 2 - 10);
      await heroes[0].add(activeIndicator);
      camera.follow(heroes[0]);
    } else {
      final singleHero = _createHeroById(config.heroId);
      heroes = [singleHero];
      await world.add(singleHero);
      activeHeroIndex = 0;
      singleHero.isActive = true;
      activeIndicator.removeFromParent();
      activeIndicator.position = Vector2(0, -singleHero.size.y / 2 - 10);
      await singleHero.add(activeIndicator);
      camera.follow(singleHero);
    }

    final startY = (config.platforms != null && config.platforms!.isNotEmpty)
        ? config.platforms!.first.position.y
        : config.levelSize.y - 150;

    // Spread all spawned heroes out on the ground
    for (int i = 0; i < heroes.length; i++) {
      heroes[i].position = Vector2(
        100.0 + (i * 100.0),
        startY - heroes[i].size.y / 2 + heroes[i].groundContactOffset,
      );
      heroes[i].velocity.setZero();

      final computedFeetY = heroes[i].position.y + (heroes[i].size.y / 2) - heroes[i].groundContactOffset;
      // ignore: avoid_print
      print('SPAWN ALIGNMENT CHECK: Hero ${heroes[i].heroName} - position.y: ${heroes[i].position.y}, computedFeetY: $computedFeetY, platformTopY: $startY, offset: ${heroes[i].groundContactOffset}, diff: ${computedFeetY - startY}');
    }

    // Reset active hero position to start of level
    activeHero.position = Vector2(
      100,
      startY - activeHero.size.y / 2 + activeHero.groundContactOffset,
    );
    activeHero.velocity.setZero();

    // Reset stats for retry robustness
    for (var hero in heroes) {
      hero.stats.reset();
    }

    // Spawn Hollow enemies on top of platforms based on config points
    if (config.enemySpawnPoints != null) {
      for (var sp in config.enemySpawnPoints!) {
        if (sp.variant == EnemyVariant.boss) {
          final boss = HollowBoss(
            bossType: config.heroId,
            position: Vector2(sp.position.x, sp.position.y),
          );
          await world.add(boss);
        } else {
          final enemy = HollowEnemy(
            variant: sp.variant,
            position: Vector2(sp.position.x, sp.position.y),
          );
          await world.add(enemy);
        }
      }
    }

    // Play looping theme music with saved volume
    final bgmFile = _getBgmForHero(config.heroId);
    playBgm(bgmFile);

    // Check for tutorial sequence
    if ((config.heroId == 'team' && !SaveManager.hasSeenTeamTutorial()) ||
        (config.heroId != 'team' && !SaveManager.hasSeenTutorial())) {
      TutorialController.instance.startTutorial(this);
    } else {
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

  void onEnemyDefeated(EnemyVariant variant) {
    // 1. Award XP to the active hero
    awardXp(CombatConstants.enemyXpAward);

    // 2. Increment total enemy deaths statistic
    final totalDeaths = SaveManager.getEnemyDeaths() + 1;
    SaveManager.saveEnemyDeaths(totalDeaths);

    // 3. Track Daily Challenge progress for "defeat_20_enemies"
    final challengeId = SaveManager.getCurrentChallengeId();
    if (challengeId == 'defeat_20_enemies') {
      final challenge = DailyChallenge.getChallengeById(challengeId);
      final progress = SaveManager.getDailyChallengeProgress() + 1;
      SaveManager.saveDailyChallengeProgress(progress);
      if (progress >= challenge.target && !SaveManager.isDailyChallengeCompleted()) {
        SaveManager.setDailyChallengeCompleted(true);
        awardDailyChallengeReward();
      }
    }

    // 4. Track boss kills achievement
    if (variant == EnemyVariant.boss) {
      final killedBosses = SaveManager.getKilledBosses();
      final bossId = currentLevelConfig?.id ?? 'generic_boss';
      if (!killedBosses.contains(bossId)) {
        killedBosses.add(bossId);
        SaveManager.saveKilledBosses(killedBosses);
      }
      if (killedBosses.length >= 5) {
        unlockAchievement('all_bosses');
      }

      // Check Daily Challenge progress for "defeat_boss_no_power"
      if (challengeId == 'defeat_boss_no_power' && !hasUsedPowerThisLevel) {
        SaveManager.setDailyChallengeCompleted(true);
        awardDailyChallengeReward();
      }
    }

    // 5. Check achievements for kills count
    if (totalDeaths >= 50) {
      unlockAchievement('defeat_50');
    }
    if (totalDeaths >= 150) {
      unlockAchievement('defeat_150');
    }
  }

  void awardXp(int amount) {
    if (heroes.isEmpty) return;
    final hero = activeHero;
    final prog = SaveManager.getHeroProgress(hero.heroName);
    final leveledUp = prog.addXp(amount);
    SaveManager.saveHeroProgress(prog);

    if (leveledUp) {
      hero.onLevelUp();

      // Check level achievements
      if (prog.level >= 5) {
        unlockAchievement('reach_level_5');
      }
      if (prog.level >= 10) {
        unlockAchievement('reach_level_10');
      }
    }
  }

  void awardDailyChallengeReward() {
    final lastPlayed = SaveManager.getLastPlayedHeroId();
    final prog = SaveManager.getHeroProgress(lastPlayed);
    prog.addXp(CombatConstants.dailyChallengeXpAward);
    SaveManager.saveHeroProgress(prog);

    unlockAchievement('daily_completed');

    if (buildContext != null) {
      ScaffoldMessenger.of(buildContext!).showSnackBar(
        SnackBar(
          content: Text(
            'DAILY CHALLENGE COMPLETED! +${CombatConstants.dailyChallengeXpAward} XP awarded to ${lastPlayed.toUpperCase()}',
            style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.black),
          ),
          backgroundColor: const Color(0xFF00FFCC),
        ),
      );
    }
  }

  void unlockAchievement(String id) {
    final unlocked = SaveManager.getUnlockedAchievements();
    if (!unlocked.contains(id)) {
      unlocked.add(id);
      SaveManager.saveUnlockedAchievements(unlocked);

      final list = Achievement.getAchievements();
      final ach = list.firstWhere((a) => a.id == id);
      if (buildContext != null) {
        NotificationToast.showAchievement(buildContext!, ach.title, ach.description);
      }
    }
  }
}


