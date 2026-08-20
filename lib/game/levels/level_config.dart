import 'package:flame/extensions.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';

class LevelConfig {
  final String id;
  final String displayName;
  final String heroId; // 'dragon', 't-rex', 'curator', 'shark', 'kitsune', 'team'
  final String backgroundAssetPath;
  final Vector2 levelSize;
  final List<StoryEntry>? introSequence;

  const LevelConfig({
    required this.id,
    required this.displayName,
    required this.heroId,
    required this.backgroundAssetPath,
    required this.levelSize,
    this.introSequence,
  });
}
