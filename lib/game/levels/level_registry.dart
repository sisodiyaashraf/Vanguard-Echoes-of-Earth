import 'package:flame/extensions.dart';
import 'level_config.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class LevelRegistry {
  static final List<LevelConfig> levels = [
    // --- DRAGON LEVELS (Fire/Sky) ---
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
        PlatformData(position: Vector2(0, 450), size: Vector2(600, 150)),
        PlatformData(position: Vector2(700, 350), size: Vector2(300, 40)),
        PlatformData(position: Vector2(1100, 250), size: Vector2(400, 40), isBreakable: true),
        PlatformData(position: Vector2(1600, 450), size: Vector2(400, 150)),
      ],
      enemySpawnPoints: [
        EnemySpawnData(position: Vector2(350, 386), variant: EnemyVariant.soldier),
        EnemySpawnData(position: Vector2(1300, 186), variant: EnemyVariant.scout),
        EnemySpawnData(position: Vector2(1800, 386), variant: EnemyVariant.brute),
      ],
    ),
    LevelConfig(
      id: 'dragon_2',
      displayName: 'Skybreak Canyon',
      heroId: 'dragon',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'dragon_3',
      displayName: 'The Hollow Forge',
      heroId: 'dragon',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'dragon_4',
      displayName: 'Storm Reckoning',
      heroId: 'dragon',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
    ),
    LevelConfig(
      id: 'dragon_5',
      displayName: "Dragon's Trial",
      heroId: 'dragon',
      backgroundAssetPath: 'backgrounds/fire_sky.png',
      levelSize: Vector2(2000, 600),
    ),

    // --- T-REX LEVELS (Earth) ---
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

    // --- CURATOR LEVELS (Ancient) ---
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

    // --- SHARK LEVELS (Water) ---
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

    // --- KITSUNE LEVELS (Urban) ---
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

    // --- TEAM LEVELS (Finale) ---
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
