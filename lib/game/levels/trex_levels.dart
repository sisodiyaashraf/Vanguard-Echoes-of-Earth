import 'package:flame/extensions.dart';
import 'level_config.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class TRexLevels {
  static final List<LevelConfig> levels = [
    LevelConfig(
      id: 'trex_1',
      displayName: 'Cave-In Memory',
      heroId: 't-rex',
      backgroundAssetPath: 'backgrounds/earth_underground.png',
      levelSize: Vector2(2000, 600),
      introSequence: [
        const StoryEntry(
          speakerName: 'T-Rex',
          portraitAssetPath: 'assets/images/characters/Hero 2 T-Rex (Seismic Hammer).png',
          text: 'Back in the mineshafts... This is where my ambition buried my team. I won\'t let anyone down this time.',
        ),
      ],
      platforms: [
        PlatformData(position: Vector2(0, 450), size: Vector2(800, 150)),
        PlatformData(position: Vector2(900, 320), size: Vector2(400, 40)),
        PlatformData(position: Vector2(1400, 450), size: Vector2(600, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(400, 386), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1100, 256), variant: EnemyVariant.brute),
        EnemySpawnData(position: Vector2(1600, 386), variant: EnemyVariant.scout),
      ],
    ),
    LevelConfig(
      id: 'trex_2',
      displayName: 'Quarry Depths',
      heroId: 't-rex',
      backgroundAssetPath: 'backgrounds/earth_underground.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'trex_3',
      displayName: 'Foundation Breach',
      heroId: 't-rex',
      backgroundAssetPath: 'backgrounds/earth_underground.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'trex_4',
      displayName: 'The Buried City',
      heroId: 't-rex',
      backgroundAssetPath: 'backgrounds/earth_underground.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'trex_5',
      displayName: "T-Rex's Trial",
      heroId: 't-rex',
      backgroundAssetPath: 'backgrounds/earth_underground.png',
      levelSize: Vector2(2000, 600),
    ),
  ];
}
