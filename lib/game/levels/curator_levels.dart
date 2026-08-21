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
    ),
    LevelConfig(
      id: 'curator_2',
      displayName: 'Sands of Memory',
      heroId: 'curator',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'curator_3',
      displayName: 'The Archive',
      heroId: 'curator',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'curator_4',
      displayName: 'Fading Self',
      heroId: 'curator',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'curator_5',
      displayName: "Curator's Trial",
      heroId: 'curator',
      backgroundAssetPath: 'backgrounds/ancient_museum.png',
      levelSize: Vector2(2000, 600),
    ),
  ];
}
