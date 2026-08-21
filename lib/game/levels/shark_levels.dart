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
    ),
    LevelConfig(
      id: 'shark_2',
      displayName: 'Tide Break',
      heroId: 'shark',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'shark_3',
      displayName: 'Abyss Trench',
      heroId: 'shark',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'shark_4',
      displayName: 'Flooded Harbor',
      heroId: 'shark',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'shark_5',
      displayName: "Shark's Trial",
      heroId: 'shark',
      backgroundAssetPath: 'backgrounds/water_ocean.png',
      levelSize: Vector2(2000, 600),
    ),
  ];
}
