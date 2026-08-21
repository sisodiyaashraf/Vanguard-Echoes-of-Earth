import 'package:flame/extensions.dart';
import 'level_config.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class KitsuneLevels {
  static final List<LevelConfig> levels = [
    LevelConfig(
      id: 'kitsune_1',
      displayName: 'Ghost of the Street',
      heroId: 'kitsune',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
      levelSize: Vector2(2000, 600),
      introSequence: [
        const StoryEntry(
          speakerName: 'Kitsune',
          portraitAssetPath: 'assets/images/characters/Kitsune (Holographic).png',
          text: 'Back in the neon alleys where I grew up as a street thief. Masks on, illusions ready.',
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
      id: 'kitsune_2',
      displayName: 'Signal Maze',
      heroId: 'kitsune',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
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
      id: 'kitsune_3',
      displayName: 'The Masquerade',
      heroId: 'kitsune',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
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
      id: 'kitsune_4',
      displayName: 'Static Heart',
      heroId: 'kitsune',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
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
      id: 'kitsune_5',
      displayName: "Kitsune's Trial",
      heroId: 'kitsune',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
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
