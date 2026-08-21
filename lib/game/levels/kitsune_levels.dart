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
    ),
    LevelConfig(
      id: 'kitsune_2',
      displayName: 'Signal Maze',
      heroId: 'kitsune',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'kitsune_3',
      displayName: 'The Masquerade',
      heroId: 'kitsune',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'kitsune_4',
      displayName: 'Static Heart',
      heroId: 'kitsune',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'kitsune_5',
      displayName: "Kitsune's Trial",
      heroId: 'kitsune',
      backgroundAssetPath: 'backgrounds/urban_tech.png',
      levelSize: Vector2(2000, 600),
    ),
  ];
}
