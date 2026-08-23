import 'package:flame/extensions.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_config.dart';
import 'package:vanguard_echoes_of_earth/game/core/platform_data.dart';

class SurvivalConfig extends LevelConfig {
  SurvivalConfig()
      : super(
          id: 'survival',
          displayName: 'SURVIVAL MODE',
          heroId: 'team', // Survival mode launches in team squad mode by default!
          backgroundAssetPath: 'backgrounds/urban_tech.png',
          levelSize: Vector2(2400, 600),
          platforms: [
            // Bottom Main Floor
            PlatformData(
              position: Vector2(0, 480),
              size: Vector2(2400, 120),
            ),
            // Multi-level Ledges for tactical play
            PlatformData(
              position: Vector2(300, 320),
              size: Vector2(400, 30),
            ),
            PlatformData(
              position: Vector2(1700, 320),
              size: Vector2(400, 30),
            ),
            PlatformData(
              position: Vector2(900, 200),
              size: Vector2(600, 30),
            ),
          ],
        );
}
