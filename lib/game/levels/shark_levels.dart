import 'package:flame/extensions.dart';
import 'level_config.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class SharkLevels {
  static final List<LevelConfig> levels = [
    LevelConfig(
      id: 'shark_1',
      displayName: 'The Sinking',
      heroId: 'shark',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
      levelSize: Vector2(2000, 600),
      introSequence: [
        const StoryEntry(
          speakerName: 'Shark',
          portraitAssetPath: 'assets/images/characters/Shark (Hydrokinetic Agility).png',
          text: 'The cold, dark abyss... My sub went down here. I can feel the thalassophobia creeping back.',
        ),
      ],
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(600, 150)),
        PlatformData(position: Vector2(700, 320), size: Vector2(300, 40)),
        PlatformData(position: Vector2(1100, 220), size: Vector2(350, 40)),
        PlatformData(position: Vector2(1550, 450), size: Vector2(450, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(300, 386), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(850, 256), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1250, 156), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1700, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'shark_2',
      displayName: 'Tide Break',
      heroId: 'shark',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(500, 150)),
        PlatformData(position: Vector2(600, 350), size: Vector2(250, 40)),
        PlatformData(position: Vector2(950, 250), size: Vector2(250, 40)),
        PlatformData(position: Vector2(1300, 350), size: Vector2(250, 40)),
        PlatformData(position: Vector2(1650, 450), size: Vector2(350, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(250, 386), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(725, 286), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1075, 186), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1425, 286), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1800, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'shark_3',
      displayName: 'Abyss Trench',
      heroId: 'shark',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 480), size: Vector2(350, 120)),
        PlatformData(position: Vector2(450, 360), size: Vector2(200, 40)),
        PlatformData(position: Vector2(750, 240), size: Vector2(200, 40)),
        PlatformData(position: Vector2(1050, 360), size: Vector2(200, 40)),
        PlatformData(position: Vector2(1350, 240), size: Vector2(200, 40)),
        PlatformData(position: Vector2(1650, 450), size: Vector2(350, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(150, 416), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(550, 296), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(850, 176), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1150, 296), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1450, 176), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1800, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'shark_4',
      displayName: 'Flooded Harbor',
      heroId: 'shark',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
      levelSize: Vector2(2000, 600),
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(500, 150)),
        PlatformData(position: Vector2(600, 450), size: Vector2(200, 150), isBreakable: true),
        PlatformData(position: Vector2(900, 320), size: Vector2(350, 40)),
        PlatformData(position: Vector2(1350, 450), size: Vector2(200, 150), isBreakable: true),
        PlatformData(position: Vector2(1650, 450), size: Vector2(350, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(250, 386), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(700, 386), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1075, 256), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1450, 386), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1800, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'shark_5',
      displayName: "Shark's Trial",
      heroId: 'shark',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
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
