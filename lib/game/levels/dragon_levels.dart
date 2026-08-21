import 'package:flame/extensions.dart';
import 'level_config.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class DragonLevels {
  static final List<LevelConfig> levels = [
    LevelConfig(
      id: 'dragon_1',
      displayName: 'Ashfall Ruins',
      heroId: 'dragon',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
      introSequence: [
        const StoryEntry(
          speakerName: 'Dragon',
          portraitAssetPath: 'assets/images/characters/Hero 1 Dragon — Kinetic Scales.png',
          text: 'Entering Ashfall Ruins. The air is thick with smoke... it feels exactly like the day I lost my sibling.',
        ),
      ],
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(400, 150)),
        PlatformData(position: Vector2(500, 350), size: Vector2(200, 40)),
        PlatformData(position: Vector2(800, 200), size: Vector2(150, 40)),
        PlatformData(position: Vector2(1100, 300), size: Vector2(250, 40), isBreakable: true),
        PlatformData(position: Vector2(1450, 200), size: Vector2(150, 40)),
        PlatformData(position: Vector2(1700, 450), size: Vector2(300, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(200, 386), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(875, 136), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1225, 236), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1525, 136), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1850, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'dragon_2',
      displayName: 'Skybreak Canyon',
      heroId: 'dragon',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 480), size: Vector2(300, 120)),
        PlatformData(position: Vector2(400, 320), size: Vector2(200, 40)),
        PlatformData(position: Vector2(700, 160), size: Vector2(200, 40)),
        PlatformData(position: Vector2(1000, 300), size: Vector2(250, 40)),
        PlatformData(position: Vector2(1350, 140), size: Vector2(200, 40)),
        PlatformData(position: Vector2(1650, 450), size: Vector2(350, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(500, 256), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(800, 96), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1125, 236), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1450, 76), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1825, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'dragon_3',
      displayName: 'The Hollow Forge',
      heroId: 'dragon',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(500, 150)),
        PlatformData(position: Vector2(500, 450), size: Vector2(300, 150), isBreakable: true),
        PlatformData(position: Vector2(800, 450), size: Vector2(400, 150)),
        PlatformData(position: Vector2(1200, 450), size: Vector2(300, 150), isBreakable: true),
        PlatformData(position: Vector2(1500, 450), size: Vector2(500, 150)),
        PlatformData(position: Vector2(600, 280), size: Vector2(200, 30), isBreakable: true),
        PlatformData(position: Vector2(1300, 280), size: Vector2(200, 30), isBreakable: true),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(300, 386), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(700, 216), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1000, 386), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1400, 216), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1750, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'dragon_4',
      displayName: 'Storm Reckoning',
      heroId: 'dragon',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(400, 150)),
        PlatformData(position: Vector2(450, 350), size: Vector2(300, 40)),
        PlatformData(position: Vector2(800, 350), size: Vector2(400, 40)),
        PlatformData(position: Vector2(1250, 350), size: Vector2(300, 40)),
        PlatformData(position: Vector2(1600, 450), size: Vector2(400, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(200, 386), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(500, 286), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(650, 286), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(900, 286), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1100, 286), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1400, 286), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1800, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'dragon_5',
      displayName: "Dragon's Trial",
      heroId: 'dragon',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(2000, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(1200, 354), variant: EnemyVariant.boss),
      ],
    ),
  ];
}
