import 'package:flame/extensions.dart';
import 'level_config.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class CuratorLevels {
  static final List<LevelConfig> levels = [
    LevelConfig(
      id: 'curator_1',
      displayName: 'The Heist Echo',
      heroId: 'curator',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
      levelSize: Vector2(2000, 600),
      introSequence: [
        const StoryEntry(
          speakerName: 'Curator',
          portraitAssetPath: 'assets/images/characters/Curator (Temporal Nanotech).png',
          text: 'The museum halls. Where I triggered the temporal relic to save a life, at the cost of my own memories.',
        ),
      ],
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(600, 150)),
        PlatformData(position: Vector2(700, 320), size: Vector2(300, 40)),
        PlatformData(position: Vector2(1100, 250), size: Vector2(400, 40)),
        PlatformData(position: Vector2(1600, 450), size: Vector2(400, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(350, 386), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(850, 256), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1300, 186), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1800, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'curator_2',
      displayName: 'Sands of Memory',
      heroId: 'curator',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(500, 150)),
        PlatformData(position: Vector2(600, 320), size: Vector2(300, 40)),
        PlatformData(position: Vector2(1000, 220), size: Vector2(300, 40)),
        PlatformData(position: Vector2(1400, 350), size: Vector2(600, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(300, 386), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(750, 256), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1150, 156), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1700, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'curator_3',
      displayName: 'The Archive',
      heroId: 'curator',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(400, 150)),
        PlatformData(position: Vector2(500, 320), size: Vector2(250, 40)),
        PlatformData(position: Vector2(850, 220), size: Vector2(250, 40)),
        PlatformData(position: Vector2(1200, 320), size: Vector2(250, 40)),
        PlatformData(position: Vector2(1550, 450), size: Vector2(450, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(200, 386), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(625, 256), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(975, 156), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1325, 256), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1750, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'curator_4',
      displayName: 'Fading Self',
      heroId: 'curator',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(500, 150)),
        PlatformData(position: Vector2(550, 300), size: Vector2(200, 40)),
        PlatformData(position: Vector2(850, 180), size: Vector2(200, 40)),
        PlatformData(position: Vector2(1150, 300), size: Vector2(200, 40)),
        PlatformData(position: Vector2(1450, 450), size: Vector2(550, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(250, 386), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(650, 236), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(950, 116), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1250, 236), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1700, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'curator_5',
      displayName: "Curator's Trial",
      heroId: 'curator',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
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
