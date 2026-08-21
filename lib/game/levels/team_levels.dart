import 'package:flame/extensions.dart';
import 'level_config.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class TeamLevels {
  static final List<LevelConfig> levels = [
    LevelConfig(
      id: 'team_1',
      displayName: 'Assembly',
      heroId: 'team',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
      levelSize: Vector2(2000, 600),
      introSequence: [
        const StoryEntry(
          speakerName: 'Narrator',
          text: 'The Vanguard stands united at the gates of the Hollow Base. Five souls, one final destiny.',
        ),
      ],
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(500, 150)),
        PlatformData(position: Vector2(600, 350), size: Vector2(300, 40)),
        PlatformData(position: Vector2(1000, 250), size: Vector2(400, 40)),
        PlatformData(position: Vector2(1500, 450), size: Vector2(500, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(300, 386), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(750, 286), variant: EnemyVariant.swarm),
        EnemySpawnData(position: Vector2(1200, 186), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1700, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'team_2',
      displayName: 'The Rift Advance',
      heroId: 'team',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'team_3',
      displayName: 'Fractured Ground',
      heroId: 'team',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'team_4',
      displayName: 'The Hollow\'s Heart',
      heroId: 'team',
      backgroundAssetPath: 'backgrounds/earth_underground.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'team_5',
      displayName: 'Echoes of Earth',
      heroId: 'team',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
      levelSize: Vector2(2000, 600),
    ),
  ];
}
