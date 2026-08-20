import 'package:flame/extensions.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';
import 'package:vanguard_echoes_of_earth/game/core/combat_constants.dart';

class EnemySpawnData {
  final Vector2 position;
  final EnemyVariant variant;

  const EnemySpawnData({
    required this.position,
    required this.variant,
  });
}

class LevelConfig {
  final String id;
  final String displayName;
  final String heroId; // 'dragon', 't-rex', 'curator', 'shark', 'kitsune', 'team'
  final String backgroundAssetPath;
  final Vector2 levelSize;
  final List<StoryEntry>? introSequence;
  final List<PlatformData>? platforms;
  final List<EnemySpawnData>? enemySpawnPoints;

  const LevelConfig({
    required this.id,
    required this.displayName,
    required this.heroId,
    required this.backgroundAssetPath,
    required this.levelSize,
    this.introSequence,
    this.platforms,
    this.enemySpawnPoints,
  });
}
